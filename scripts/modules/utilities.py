import time
import pandas as pd


def timer_decorator(func):
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        print(f"Function {func.__name__} took {end_time - start_time} seconds to run.")
        return result
    return wrapper


def downcast_df(df, verbose=False):
    # Downcast columns of type 'integer' and 'float' to the smallest type that can hold all values
    for col in df.select_dtypes('number'):
        df[col] = pd.to_numeric(df[col], downcast='integer')
        if df[col].dtype == 'float':
            df[col] = pd.to_numeric(df[col], downcast='float')
    # note that setting the verbose flag to True will severely slow down the function
    if verbose: 
        print(df.dtypes)
    return df

