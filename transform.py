import pandas as pd
import sys

def transform(input_file, output_file):
    # Try reading CSV with UTF-8 encoding, fallback to ISO-8859-1
    try:
        df = pd.read_csv(input_file, encoding='utf-8')
    except UnicodeDecodeError:
        print("⚠️ UTF-8 failed. Trying ISO-8859-1 encoding.")
        df = pd.read_csv(input_file, encoding='ISO-8859-1')

    # Transformation: Add a new column "Age_in_5_years"
    if 'Age' in df.columns:
        df['Age_in_5_years'] = df['Age'] + 5

    # Save the transformed CSV
    df.to_csv(output_file, index=False)
    print(f"✅ Transformation complete. Check: {output_file}")

if __name__ == "__main__":
    transform(sys.argv[1], sys.argv[2])
