#!/usr/bin/env python3

import sys
import json
import os.path
from datetime import datetime, timedelta
from sqlalchemy import create_engine, text
from collections import defaultdict
import matplotlib
matplotlib.use('Agg') #no X
import matplotlib.pyplot as plt
import pandas as pd
import yaml


GRAPHOUTPATH = "../graphs"

with open("secrets.yaml",'rb') as f:
    secrets = yaml.load(f)

with open("groups.yaml",'rb') as f:
    groups = yaml.load(f)

group_entities = set()
for group, values in groups.items():
    if 'entities' in values:
        for entity in values['entities']:
            group_entities.add(entity)

# setting up a visual style for PyPlot, much better than the standard
plt.style.use('ggplot')

DB_URL = secrets['db_url']
engine = create_engine(DB_URL)

print("Counting and plotting changes per entity...")
# executing our SQL query against the database and storing the output
entityquery = engine.execute("SELECT entity_id, COUNT(*) FROM states GROUP BY entity_id ORDER by 2 DESC")

# fetching th equery reults and reading it into a DataFrame
entitycallsDF = pd.DataFrame(entityquery.fetchall())

# naming the dataframe columns
entitycallsDF.columns = ['entity', 'Number of Changes']

# setting the entity name as an index of a new dataframe and sorting it by the Number of Changes
ordered_indexed_df = entitycallsDF.set_index(['entity']).sort_values(by='Number of Changes')

# displaying the data as a horizontal bar plot with a title and no legend
changesplot = ordered_indexed_df.plot(kind='barh', title='Number of Changes to Home Assistant per entity', figsize=(15, 80), legend=False)
# specifying labels for the X and Y axes
changesplot.set_xlabel('Number of Changes')
changesplot.set_ylabel('Entity name')
changesplot.get_figure().savefig(os.path.join(GRAPHOUTPATH,"changes.png"))
plt.close("all")

print("Obtaining entity information...")

entity_attributes = {}
unit_entities = defaultdict(set)
infoquery = engine.execute("SELECT entity_id, attributes, max(last_changed) FROM `states` GROUP BY entity_id")
for row in infoquery.fetchall():
    attributes = json.loads(row['attributes'])
    entity_attributes[row['entity_id']] = attributes
    if 'unit_of_measurement' in attributes:
        unit_entities[attributes['unit_of_measurement']].add(row['entity_id'])


periods = (2, 10,30,60,90,180)

for period in periods:
    print("Processing period: ", period,file=sys.stderr)


    #columns = ['state_id', 'domain', 'entity_id', 'state', 'attributes', 'event_id', 'last_changed', 'last_updated', 'created']
    columns = ['entity_id', 'domain', 'state', 'last_changed']

    # query to pull all rows form the states table where last_changed field is on or after the date_filter value
    stmt = text("SELECT " + ", ".join(columns) + " FROM states WHERE last_changed>=:date_filter AND state != 'unknown'")

    # bind parameters to the stmt value, specifying the date_filter to be a certain number of days before today
    stmt = stmt.bindparams(date_filter=datetime.now()-timedelta(days=period))

    # execute the SQL statement
    allquery = engine.execute(stmt)

    # get rows from query into a pandas dataframe
    print("fetching data..")
    allqueryDF = pd.DataFrame(allquery.fetchall())

    # name the dataframe rows for usability
    allqueryDF.columns = columns

    # split the json from the 'attributes' column and 'concat' to existing dataframe as separate columns
    #print("splitting json..")
    #allqueryDF = pd.concat([allqueryDF, allqueryDF['attributes'].apply(get_units).apply(pd.Series)], axis=1)
    #del allqueryDF['attributes']

    print("changing last_changed datetype...")
    # change the last_changed datatype to datetime
    allqueryDF['last_changed'] = pd.to_datetime(allqueryDF['last_changed'])
    # use it as the index of our dataframe

    print("plotting binary data...")
    binary = allqueryDF['domain'] == 'binary_sensor'
    wanted = allqueryDF['entity_id'].isin(group_entities)
    cdf = allqueryDF[binary & wanted].copy()
    # convert the 'state' column to a bool
    cdf['state'] = cdf['state'].map(lambda x: 1.0 if x.lower() in ('true','yes','on','open','home') else 0.0)
    cdf.index = cdf['last_changed']

    groupbyName = cdf.groupby(['entity_id'])
    for key, group in groupbyName:
        print(key,file=sys.stderr)
        tempgroup = group.copy()
        tempgroup.rename(columns={'state': key}, inplace=True)
        ax = tempgroup[[key]].plot(title=entity_attributes[key]['friendly_name'], drawstyle='steps-post',legend=False, figsize=(10, 8))
        # create a mini-dataframe for each of the groups
        df = groupbyName.get_group(key)

        # resample the mini-dataframe on the index for each Day, get the mean and plot it
        if period <= 2:
            bx = df['state'].resample('H').sum().plot(label='Hourly sum', drawstyle='steps-post',legend=False)
        else:
            bx = df['state'].resample('D').sum().plot(label='Daily sum', drawstyle='steps-post',legend=False)
        ax.set_ylabel('State')
        ax.set_xlabel('Date')
        ax.legend()
        ax.get_figure().savefig(os.path.join(GRAPHOUTPATH, key.lower().replace(' ','_')+'.' + str(period) + 'd.png'), bbox_inches='tight')
        plt.close("all")

    del cdf

    print("plotting numeric data...")
    # let's chart data for each of the unique units of measurement
    for unit in unit_entities.keys():
        # filter down our original dataset to only contain the unique unit of \
        # measurement, and removing the unknown values
        print(unit,file=sys.stderr)

        # Create variable with TRUE if age is state is not unknown
        notunknown = allqueryDF['state'] != 'unknown'
        wanted = allqueryDF['entity_id'].isin(group_entities & unit_entities[unit])

        # Select all rows satisfying the requirement: unit_of_measurement \
        # matching the current unit and not having an 'unknown' status
        cdf = allqueryDF[notunknown & wanted].copy()

        # convert the last_changed 'object' to 'datetime' and use it as the index \
        # of our new concatenated dataframe
        cdf.index = cdf['last_changed']

        # convert the 'state' column to a float
        cdf['state'] = cdf['state'].astype(float, errors='ignore')

        # create a groupby object for each of the friendly_name values
        groupbyName = cdf.groupby(['entity_id'])

        # build a separate chart for each of the friendly_name values
        for key, group in groupbyName:
            print("Processing " + key + " (" + str(period)+")",file=sys.stderr)

            # since we will be plotting the 'State' column, let's rename it to \
            # match the groupby key (distinct friendly_name value)
            tempgroup = group.copy()
            tempgroup.rename(columns={'state': key}, inplace=True)

            # plot the values, specify the figure size and title
            try:
                ax = tempgroup[[key]].plot(title=entity_attributes[key]['friendly_name'], legend=False, figsize=(10, 8))
            except TypeError as e:
                print("Unable to plot " + key + ": " + str(e),file=sys.stderr)
                continue

            # create a mini-dataframe for each of the groups
            df = groupbyName.get_group(key)

            # resample the mini-dataframe on the index for each Day, get the mean and plot it
            if period <= 2:
                bx = df['state'].resample('H').mean().plot(label='Mean hourly value', legend=False)
            else:
                bx = df['state'].resample('D').mean().plot(label='Mean daily value', legend=False)

            # set the axis labels and display the legend
            ax.set_ylabel(unit)
            ax.set_xlabel('Date')
            ax.legend()
            ax.get_figure().savefig(os.path.join(GRAPHOUTPATH, key.lower().replace(' ','_')+'.' + str(period) + 'd.png'), bbox_inches='tight')
            plt.close("all")

    del allqueryDF
