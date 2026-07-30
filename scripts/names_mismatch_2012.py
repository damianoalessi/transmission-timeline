def fix_wrong_names(df):
    from_col = ('2012', 'Inv_Substation From')
    to_col = ('2012', 'Inv_Substation To')
    idx_col = ('2012', 'Inv_index')

    df_2012 = df['2012']

    df_2012.loc[df_2012[from_col].str.strip() == "JM Oriol (ES)", idx_col] = "4. 21a"
    df_2012.loc[df_2012[from_col].str.strip() == "La Serna (ES)", idx_col] = "7. 23a"
    df_2012.loc[(df_2012[idx_col] == "7. 23") & df_2012[from_col].str.contains("Tudela", na=False), idx_col] = "7. 23b"
    df_2012.loc[(df_2012[idx_col] == "6. 22") & df_2012[from_col].str.contains("Soto -Grado", na=False), idx_col] = "6. 22a"
    df_2012.loc[(df_2012[idx_col] == "6. 22") & df_2012[from_col].str.contains("Soto", na=False) & df_2012[to_col].str.contains("Penagos", na=False), idx_col] = "6. 22b"
    df_2012.loc[(df_2012[idx_col] == "6. 22") & df_2012[from_col].str.contains("Sama", na=False) & df_2012[to_col].str.contains("Velilla", na=False), idx_col] = "6. 22c"
    df_2012.loc[(df_2012[idx_col] == "6. 22") & df_2012[from_col].str.contains("Lada", na=False) & df_2012[to_col].str.contains("Robla", na=False), idx_col] = "6. 22d"
    df_2012.loc[(df_2012[idx_col] == "6. 22") & df_2012[from_col].str.contains("Penagos", na=False) & df_2012[to_col].str.contains("Abanto", na=False), idx_col] = "6. 22e"
    df_2012.loc[(df_2012[idx_col] == "6. 22") & df_2012[from_col].str.contains("Zierbena", na=False) & df_2012[to_col].str.contains("Abanto", na=False), idx_col] = "6. 22f"
    df_2012.loc[(df_2012[idx_col] == "6. 22") & df_2012[from_col].str.contains("Gueñes", na=False) & df_2012[to_col].str.contains("Ichaso", na=False), idx_col] = "6. 22g"
    df_2012.loc[(df_2012[idx_col] == "7. 23") & df_2012[from_col].str.contains("Tudela", na=False), idx_col] = "7. 23b"
    df_2012.loc[(df_2012[idx_col] == "8. 25") & df_2012[from_col].str.contains("Escatron", na=False), idx_col] = "8. 25a"
    df_2012.loc[(df_2012[idx_col] == "9. 26") & df_2012[to_col].str.contains("Jijona", na=False), idx_col] = "9. 26a"
    df_2012.loc[(df_2012[idx_col] == "10. 28") & df_2012[from_col].str.contains("Ayora", na=False), idx_col] = "10. 28a"
    df_2012.loc[(df_2012[idx_col] == "10. 33") & df_2012[from_col].str.contains("Manzanares", na=False), idx_col] = "10. 33a"
    df_2012.loc[(df_2012[idx_col] == "10. 34") & df_2012[from_col].str.contains("Tordesillas", na=False), idx_col] = "10. 34a"
    df_2012.loc[(df_2012[idx_col] == "10. 34") & df_2012[from_col].str.contains("Segovia", na=False), idx_col] = "10. 34b"
    df_2012.loc[(df_2012[idx_col] == "10. 34") & df_2012[from_col].str.contains("Loeches", na=False), idx_col] = "10. 34c"
    df_2012.loc[(df_2012[idx_col] == "12. 30") & df_2012[from_col].str.contains("Guillena", na=False), idx_col] = "12. 30a"
    df_2012.loc[(df_2012[idx_col] == "13. 31") & df_2012[to_col].str.contains("Litoral", na=False), idx_col] = "13. 31a"
    df_2012.loc[(df_2012[idx_col] == "14. 34") & df_2012[from_col].str.contains("Tordesillas ", na=False), idx_col] = "14. 34a"
    df_2012.loc[(df_2012[idx_col] == "14. 34") & df_2012[from_col].str.contains("Segovia", na=False), idx_col] = "14. 34b"
    df_2012.loc[(df_2012[idx_col] == "14. 34") & df_2012[from_col].str.contains("Loeches", na=False), idx_col] = "14. 34c"
    df_2012.loc[(df_2012[idx_col] == "14. 34") & df_2012[from_col].str.contains("Fuencarral", na=False), idx_col] = "14. 34d"
    df_2012.loc[(df_2012[idx_col] == "14. 34") & df_2012[from_col].str.contains("Mudarra", na=False), idx_col] = "14. 34e"


    df['2012'] = df_2012
    return df
