import os
import glob
import pandas as pd

csv_file = '~/Downloads/rcsb_pdb_custom_report_20231006144324.csv'

df = pd.read_csv(csv_file)
print(df)