import pandas as pd
import sys

def transform(input_file, output_file):
    # Read the CSV file
    df = pd.read_csv(input_file)

    # Transformation: Add a new column "Age_in_5_years"
    df['Age_in_5_years'] = df['Age'] + 5

    # Save the transformed data
    df.to_csv(output_file, index=False)
    print("Transformation complete! Check the output CSV.")

if __name__ == "__main__":
    transform(sys.argv[1], sys.argv[2])
