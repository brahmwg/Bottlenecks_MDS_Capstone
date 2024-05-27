from lib2to3.pgen2.pgen import DFAState
import pandas as pd

def create_data():
    unique = {
        'species':['chinook',
                'coho',
                'chum',
                'pink',
                'sockeye',
                'steelhead',
                'cutthroat'],
        'eye_size':['large',
                    'large',
                    'medium',
                    'medium',
                    'very large',
                    'small',
                    'small'],
        'snout_shape':['pointy',
                    'short and blunt',
                    'NA',
                    'NA',
                    'NA',
                    'short and rounded',
                    'long and pointy'],
        'parr_marks':['slightly faded',
                    'slightly faded',
                    'faded',
                    'NA',
                    'slightly faded',
                    'faded',
                    'faded'],
        'parr_marks_length':['long',
                            'long',
                            'short',
                            'NA',
                            'irregular',
                            'short',
                            'short'],
        'spotting_density':['medium',
                            'medium',
                            'medium',
                            'NA',
                            'NA',
                            'high',
                            'high'],
        'fin_type':['anal fin',
                    'anal fin',
                    'caudal fin',
                    'caudal fin',
                    'caudal fin',
                    'caudal fin',
                    'caudal fin']
        
    }

    df = pd.DataFrame(unique)

    df = df.sample(1000, replace=True)

    return df


if __name__ == '__main__':
    df = create_data()

    df.to_csv('./data/species_data.csv')


