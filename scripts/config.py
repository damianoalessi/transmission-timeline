# config.py

# File paths for TYNDP data
TYNDP_DATA_PATHS = {
    '2010': 'Data/TYNDP 2010.xls',
    '2012': 'Data/TYNDP 2012.xlsx',
    '2013': 'Data/TYNDP 2013.xlsx',
    '2014': 'Data/TYNDP 2014.xlsx',
    '2015': 'Data/TYNDP 2015.xlsx',
    '2016': 'Data/TYNDP 2016.xlsx',    
    '2018': 'Data/TYNDP 2018.xlsx',
    '2020_invest': 'Data/TYNDP 2020.xlsx',
    '2020_projects': 'Data/TYNDP 2020.xlsx',
    '2022_invest': 'Data/TYNDP 2022.xlsx',
    '2022_projects': 'Data/TYNDP 2022.xlsx',
    '2024_invest': 'Data/TYNDP 2024.xlsx',
    '2024_projects': 'Data/TYNDP 2024.xlsx',
    '2026_invest': 'Data/TYNDP 2026.xlsx',
    '2026_projects': 'Data/TYNDP 2026.xlsx',
}

# Sheet names for each dataset
SHEET_NAMES = {
    '2010': 'TABLE OF PROJECTS',
    '2012': 'TYNDP 2012 report',
    '2013': 'Monitoring update',
    '2014': 'Investments',
    '2015': 'Table 1',    
    '2016': 'Investments',    
    '2018': 'TYNDP 2018 Projects',
    '2020_invest': 'Trans.Investments',
    '2020_projects': 'Trans.Projects',
    '2022_invest': 'Trans.Investments',
    '2022_projects': 'Trans.Projects',
    '2024_invest': 'Trans.Investments',
    '2024_projects': 'Trans.Projects',
    '2026_invest': 'Transmission Investments',
    '2026_projects': 'Transmission Projects',
}




# Rows to skip for each sheet
SKIP_ROWS = {
    '2010': 2,
    '2012': 4,
    '2013': 4,
    '2014': 0,
    '2015': 21,
    '2016': 0,
    '2018': 0,
    '2020_invest': 1,
    '2020_projects': 1,
    '2022_invest': 1,
    '2022_projects': 1,
    '2024_invest': 1,
    '2024_projects': 1,
    '2026_invest': 3,
    '2026_projects': 3,
}
