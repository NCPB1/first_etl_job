import pandas as pd
import sys

def transform(input_file, output_file):
    df = pd.read_csv(input_file)

    # Example transformation: Convert all text to uppercase
    df = df.apply(lambda x: x.str.upper() if x.dtype == "object" else x)

    df.to_csv(output_file, index=False)
    print("Transformation Completed!")

if __name__ == "__main__":
    transform(sys.argv[1], sys.argv[2])
