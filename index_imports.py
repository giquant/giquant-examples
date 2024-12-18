def print_df(df):
  print(df)
  return df

def print_(df, y):
  cols = df.columns[list(map(lambda x: not re.search(f'^.*{y}', x) is None, df.columns))]
  print(df[cols])
  print(cols)
  return df

def log(x):
  return np.log10(x)

def lag_(x, n):
  n = int(n)
  return np.insert(x[:-n], 0, np.repeat(np.nan, n))

# works with matrix
def lagone(x):
  if not isinstance(x, np.ndarray):
    x = x.to_numpy()
  return np.insert(x[:-1,:], 0, np.repeat(np.nan, x.shape[1]), axis=0)

def cummax(x):
  if not isinstance(x, np.ndarray):
    x = x.to_numpy()
  return np.apply_along_axis(np.maximum.accumulate, axis=0, arr=x)

def inf_to_nan(y):
  y[(y==-np.inf) | (y==np.inf)] = np.nan
  return y

def cummean(x):
  if not isinstance(x, np.ndarray):
    x = x.to_numpy()
  n1 = np.cumsum((~np.isnan(x))*1)
  x = np.nan_to_num(x, posinf=0, neginf=0)
  res = np.apply_along_axis(np.add.accumulate, axis=0, arr=x) / n1
  return res

def cumstd(x):
  if not isinstance(x, np.ndarray):
    x = x.to_numpy()
  x1 = [ x[0:i] for i in range(1,len(x)+1)]
  x1 = list(map(inf_to_nan, x1))
  res = np.array(list(map(np.nanstd, x1)))
  return res

def drawdown(x):
  if not isinstance(x, np.ndarray):
    x = x.to_numpy()
  return (x-cummax(x))/cummax(x)

def std(x, n):
  n = int(n)
  if not isinstance(x, np.ndarray):
    x = x.to_numpy()
  x1 = np.lib.stride_tricks.sliding_window_view(x, n)
  res = np.apply_along_axis(np.std, axis=1, arr=x1)
  res = np.insert(res, 0, np.repeat(np.nan, x.shape[0]-res.shape[0]))
  return res

def agg_over_cols(df_, func_, cols_re, new_col):
  f = eval(func_)
  sel = df_.columns[list(map(lambda x: not re.search(cols_re, x) is None, df_.columns))]
  x = np.nan_to_num(df_.loc[:,sel])
  df_[new_col] = np.apply_along_axis(f, axis=1, arr=x)
  return df_

def set_initial(df_, cols_re, val):
  sel = list(map(lambda x: not re.search(cols_re, x) is None, df_.columns))
  idx = [i for i, x in enumerate(sel) if x]
  df_.iloc[0,idx] = val
  return df_

def calc_port_val(df_, initial_cash, trans_col, new_col):
  df_[new_col] = 0
  idx = list(df_.columns).index(new_col)
  df_.iloc[0,idx] = initial_cash
  df_[new_col] = df_[new_col] + df_[trans_col]
  df_[new_col] = np.cumsum(df_[new_col])
  return df_

def calc_shares_alloc(df_, alloc_col, start_capital):
  sel_alloc = df_.columns[list(map(lambda x: not re.search(f'.*_{alloc_col}', x) is None, df_.columns))]
  df_alloc = df_.loc[:,sel_alloc] / 100
  tickers =  set(list(map(lambda x: x.split('_')[0], df_alloc.columns))).difference(set(['CASH']))
  val_period_end = start_capital
  for idx,row in df_.iterrows():
    val_period_start = val_period_end
    val_period_end = 0
    val_period_invested = 0
    print(f'\n{idx} (start value:{val_period_start:.0f})', end='...', flush=True)
    for ticker in tickers:
      print(f'{ticker}', end='...', flush=True)
      df_.loc[idx, f'{ticker}_shares'] = 0.0
      if df_.loc[idx, f'{ticker}_{alloc_col}']>0:
        df_.loc[idx, f'{ticker}_shares'] =  (val_period_start * df_alloc.loc[idx, f'{ticker}_{alloc_col}']) // df_.loc[idx, f'{ticker}_Open']
        val_period_invested += df_.loc[idx, f'{ticker}_shares'] * df_.loc[idx, f'{ticker}_Open']
        val_period_end += df_.loc[idx, f'{ticker}_Close'] * df_.loc[idx, f'{ticker}_shares']
    df_.loc[idx, f'CASH_shares'] = val_period_start - val_period_invested
    val_period_end += df_.loc[idx, f'CASH_shares']
  return df_
