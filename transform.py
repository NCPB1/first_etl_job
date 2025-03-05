import pandas as pd
import sys

def transform(input_file, output_file):
    # Try reading the CSV with a fallback encoding
    try:
        df = pd.read_csv(input_file, encoding='utf-8')
    except UnicodeDecodeError:
        df = pd.read_csv(input_file, encoding='ISO-8859-1')  # Try fallback encoding

    # Example transformation (Modify as needed)
    df['new_column'] = 'transformed'

    # Save transformed data
    df.to_csv(output_file, index=False)

if __name__ == "__main__":
    transform(sys.argv[1], sys.argv[2])
