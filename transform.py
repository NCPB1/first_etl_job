import pandas as pd
import sys

def transform(input_file, output_file):
    # Determine file type
    if input_file.endswith('.csv'):
        try:
            df = pd.read_csv(input_file, encoding='utf-8')
        except UnicodeDecodeError:
            df = pd.read_csv(input_file, encoding='ISO-8859-1')
    elif input_file.endswith(('.xls', '.xlsx')):
        df = pd.read_excel(input_file)

    # Ensure consistent column handling
    df.columns = df.columns.str.strip()

    # Transformation: Add a new column
    df['new_column'] = 'transformed'

    # Save the transformed data
    df.to_csv(output_file, index=False)

if __name__ == "__main__":
    transform(sys.argv[1], sys.argv[2])
