def clean_project_data(df, column_renames):
    """
    Clean and preprocess the project data by filling missing values and handling column-specific cleanups.

    Args:
    - df (dict): Dictionary of DataFrames indexed by year
    - column_renames (dict): Column name mappings for each year

    Returns:
    - df (dict): Cleaned dictionary of DataFrames
    """
    for year in column_renames.keys():
        if 'Project_ID' in df[year].columns:
            # Clean the column values
            df[year]['Project_ID'] = (
                df[year]['Project_ID']
                .ffill()
                .astype(str)
                .str.strip()
                .str.replace(r"\.0$", "", regex=True)
            )

            # 🧼 Filter out empty, whitespace-only, or "nan"-like values
            rows_before = len(df[year])
            df[year] = df[year][
                df[year]['Project_ID']
                .astype(str)
                .str.strip()
                .str.lower()
                .replace("nan", "")
                != ""
            ]
            rows_after = len(df[year])
            print(f"{year}: {rows_before} rows before, {rows_after} rows after 'Project ID' cleanup")

        if 'Project_Name' in df[year].columns:
            df[year]['Project_Name'] = df[year]['Project_Name'].ffill()

        if 'Inv_index' in df[year].columns:
            df[year]['Inv_index'] = (
                df[year]['Inv_index']
                .fillna('')
                .astype(str)
                .str.strip()
                .str.replace(r"\.0$", "", regex=True)
            )

            rows_before = len(df[year])
            df[year] = df[year][
                (df[year]['Inv_index'].str.lower() != "nan") &
                (df[year]['Inv_index'] != "")
            ]
            rows_after = len(df[year])
            print(f"{year}: {rows_before} rows before , {rows_after} rows after 'Investment index' cleanup")

    return df
