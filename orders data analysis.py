#!/usr/bin/env python
# coding: utf-8

# In[1]:


get_ipython().system('pip install kaggle')


# In[2]:


import kaggle


# In[3]:


#downloading file to local system
get_ipython().system('kaggle datasets download ankitbansal06/retail-orders -f orders.csv')


# In[4]:


#extracting orders.csv from zipfile in local system
import zipfile
zip_extract = zipfile.ZipFile('orders.csv.zip')
zip_extract.extractall()
zip_extract.close()


# In[5]:


#read data from csv file and handle null values
#df['Ship Mode'].unique() gives 6 values out of which 2 need to be labeled as null since they are unknown/Not Available
import pandas as pd
df = pd.read_csv('orders.csv')
#for uniformity changing column names
df.columns = df.columns.str.lower()
df.columns = df.columns.str.replace(' ','_')
df.head()


# In[6]:


#creating new columns via calculations = discount, sale_price, profit
df['discount'] = df['list_price']*df['discount_percent']*0.01
df['sale_price'] = df['list_price']-df['discount']
df['profit'] = (df['sale_price'] - df['cost_price'])*df['quantity']
df.head()


# In[7]:


#drop columns that we no longer need i.e. cost_price,list_price,discount_percent since we calculated and created
#new columns accordingly
df.drop(columns = ['cost_price','list_price','discount_percent'], inplace = True)
df.head()


# In[8]:


# viewed columns datatypes and saw that order_date needs to ve changed to date type
df.dtypes


# In[9]:


#changing order_date to datetime
df['order_date']=pd.to_datetime(df['order_date'],format="%Y-%m-%d")


# In[10]:


df.dtypes


# In[11]:


import pymysql
print("pymysql is installed correctly!")


# In[14]:


import sqlalchemy as sal
from sqlalchemy import create_engine

# Create a connection to MySQL (replace with your details)
engine = create_engine("mysql+pymysql://root:vani%406839@localhost:3306/order_data_database")

# Test connection
conn = engine.connect()
print("Connected successfully!")

df.to_sql("df_orders", con=conn, if_exists="append", index=False)

print("Data inserted successfully!")


# In[ ]:




