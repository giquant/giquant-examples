#!/usr/bin/env bash
#
# https://www.cftc.gov/MarketReports/CommitmentsofTraders/ExplanatoryNotes/index.htm
#

#set -euox pipefail
set -euo pipefail

[[ -z "${TSLDBFOLDER}" ]] && echo -e "\nERROR: Environment variable TSLDBFOLDER is not set!\n" && exit 1
[[ -z "${TSLDBNAME}" ]] && echo -e "\nERROR: Environment variable TSLDBNAME is not set!\n" && exit 1
[[ -z "${TSLBACKEND}" ]] && echo -e "\nERROR: Environment variable TSLBACKEND is not set!\n" && exit 1

[[ -z "${COTFOLDER}" ]] && echo -e "\nERROR: Environment variable COTFOLDER is not set!\n" && exit 1
[[ -z "${TMPFOLDER}" ]] && echo -e "\nERROR: Environment variable TMPFOLDER is not set!\n" && exit 1
[[ -z "${TO_YEAR}" ]] && echo -e "\nERROR: Environment variable TO_YEAR is not set!\n" && exit 1
[[ -z "${FROM_YEAR}" ]] && echo -e "\nERROR: Environment variable FROM_YEAR is not set!\n" && exit 1
[[ -z "${DA_OUTFILE}" ]] && echo -e "\nERROR: Environment variable DA_OUTFILE is not set!\n" && exit 1
[[ -z "${LEGACY_OUTFILE}" ]] && echo -e "\nERROR: Environment variable LEGACY_OUTFILE is not set!\n" && exit 1


#pwd=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#SRC=$pwd/../src/trade
#SRC2=$pwd/../src/tsl


# Donwload files from CFTC
# =======================

read -p "Download COT data? (Y/N): " confirm

if [[ "$confirm" == "Y" ]]; then
  python3 -m trade.dwnl cot $COTFOLDER
fi


# New (disaggregated/financial) version
# =====================================

# Disaggregated
# -------------
#
# "Market_and_Exchange_Names",
# "As_of_Date_In_Form_YYMMDD", "Report_Date_as_YYYY-MM-DD",
# "CFTC_Contract_Market_Code", 
# "CFTC_Market_Code",
# "CFTC_Region_Code",
# "CFTC_Commodity_Code",
# "Open_Interest_All",
# "Prod_Merc_Positions_Long_All", "Prod_Merc_Positions_Short_All",
# "Swap_Positions_Long_All",      "Swap__Positions_Short_All",      "Swap__Positions_Spread_All",
# "M_Money_Positions_Long_All",   "M_Money_Positions_Short_All",    "M_Money_Positions_Spread_All",
# "Other_Rept_Positions_Long_All","Other_Rept_Positions_Short_All", "Other_Rept_Positions_Spread_All",
# "Tot_Rept_Positions_Long_All",  "Tot_Rept_Positions_Short_All",
# "NonRept_Positions_Long_All",   "NonRept_Positions_Short_All",
# "Open_Interest_Old",
# "Prod_Merc_Positions_Long_Old",
# "Prod_Merc_Positions_Short_Old",
# "Swap_Positions_Long_Old",      "Swap__Positions_Short_Old",      "Swap__Positions_Spread_Old",
# "M_Money_Positions_Long_Old",   "M_Money_Positions_Short_Old",    "M_Money_Positions_Spread_Old",
# "Other_Rept_Positions_Long_Old","Other_Rept_Positions_Short_Old", "Other_Rept_Positions_Spread_Old",
# "Tot_Rept_Positions_Long_Old",  "Tot_Rept_Positions_Short_Old",
# "NonRept_Positions_Long_Old",   "NonRept_Positions_Short_Old",
# "Open_Interest_Other",
# "Prod_Merc_Positions_Long_Other","Prod_Merc_Positions_Short_Other",
# "Swap_Positions_Long_Other",     "Swap__Positions_Short_Other",       "Swap__Positions_Spread_Other",
# "M_Money_Positions_Long_Other",  "M_Money_Positions_Short_Other",     "M_Money_Positions_Spread_Other",
# "Other_Rept_Positions_Long_Other","Other_Rept_Positions_Short_Other", "Other_Rept_Positions_Spread_Other",
# "Tot_Rept_Positions_Long_Other",  "Tot_Rept_Positions_Short_Other",   "NonRept_Positions_Long_Other",
# "NonRept_Positions_Short_Other",  "Change_in_Open_Interest_All",      
# "Change_in_Prod_Merc_Long_All",   "Change_in_Prod_Merc_Short_All", 
# "Change_in_Swap_Long_All",        "Change_in_Swap_Short_All",         "Change_in_Swap_Spread_All",
# "Change_in_M_Money_Long_All",     "Change_in_M_Money_Short_All",      "Change_in_M_Money_Spread_All",
# "Change_in_Other_Rept_Long_All",  "Change_in_Other_Rept_Short_All",   "Change_in_Other_Rept_Spread_All",
# "Change_in_Tot_Rept_Long_All",    "Change_in_Tot_Rept_Short_All",     
# "Change_in_NonRept_Long_All",     "Change_in_NonRept_Short_All",
# "Pct_of_Open_Interest_All",       "Pct_of_OI_Prod_Merc_Long_All",  "Pct_of_OI_Prod_Merc_Short_All",  
# "Pct_of_OI_Swap_Long_All",        "Pct_of_OI_Swap_Short_All",      "Pct_of_OI_Swap_Spread_All",
# "Pct_of_OI_M_Money_Long_All",     "Pct_of_OI_M_Money_Short_All",   "Pct_of_OI_M_Money_Spread_All",
# "Pct_of_OI_Other_Rept_Long_All",  "Pct_of_OI_Other_Rept_Short_All","Pct_of_OI_Other_Rept_Spread_All",
# "Pct_of_OI_Tot_Rept_Long_All",    "Pct_of_OI_Tot_Rept_Short_All",  
# "Pct_of_OI_NonRept_Long_All",     "Pct_of_OI_NonRept_Short_All",    
# "Pct_of_Open_Interest_Old",       
# "Pct_of_OI_Prod_Merc_Long_Old",   "Pct_of_OI_Prod_Merc_Short_Old",
# "Pct_of_OI_Swap_Long_Old",        "Pct_of_OI_Swap_Short_Old",       "Pct_of_OI_Swap_Spread_Old",
# "Pct_of_OI_M_Money_Long_Old",     "Pct_of_OI_M_Money_Short_Old",    "Pct_of_OI_M_Money_Spread_Old",
# "Pct_of_OI_Other_Rept_Long_Old",  "Pct_of_OI_Other_Rept_Short_Old", "Pct_of_OI_Other_Rept_Spread_Old",
# "Pct_of_OI_Tot_Rept_Long_Old",    "Pct_of_OI_Tot_Rept_Short_Old",
# "Pct_of_OI_NonRept_Long_Old",     "Pct_of_OI_NonRept_Short_Old",
# "Pct_of_Open_Interest_Other",
# "Pct_of_OI_Prod_Merc_Long_Other", "Pct_of_OI_Prod_Merc_Short_Other",
# "Pct_of_OI_Swap_Long_Other",      "Pct_of_OI_Swap_Short_Other",      "Pct_of_OI_Swap_Spread_Other",
# "Pct_of_OI_M_Money_Long_Other",   "Pct_of_OI_M_Money_Short_Other",   "Pct_of_OI_M_Money_Spread_Other",
# "Pct_of_OI_Other_Rept_Long_Other","Pct_of_OI_Other_Rept_Short_Other","Pct_of_OI_Other_Rept_Spread_Other",
# "Pct_of_OI_Tot_Rept_Long_Other",  "Pct_of_OI_Tot_Rept_Short_Other",  "Pct_of_OI_NonRept_Long_Other",
# "Pct_of_OI_NonRept_Short_Other",
# "Traders_Tot_All",
# "Traders_Prod_Merc_Long_All", "Traders_Prod_Merc_Short_All",
# "Traders_Swap_Long_All",      "Traders_Swap_Short_All",       "Traders_Swap_Spread_All",
# "Traders_M_Money_Long_All",   "Traders_M_Money_Short_All",    "Traders_M_Money_Spread_All",
# "Traders_Other_Rept_Long_All","Traders_Other_Rept_Short_All", "Traders_Other_Rept_Spread_All",
# "Traders_Tot_Rept_Long_All",  "Traders_Tot_Rept_Short_All",
# "Traders_Tot_Old",
# "Traders_Prod_Merc_Long_Old", "Traders_Prod_Merc_Short_Old",
# "Traders_Swap_Long_Old",      "Traders_Swap_Short_Old",       "Traders_Swap_Spread_Old",
# "Traders_M_Money_Long_Old",   "Traders_M_Money_Short_Old",   "Traders_M_Money_Spread_Old",
# "Traders_Other_Rept_Long_Old","Traders_Other_Rept_Short_Old","Traders_Other_Rept_Spread_Old",
# "Traders_Tot_Rept_Long_Old",  "Traders_Tot_Rept_Short_Old",
# "Traders_Tot_Other",
# "Traders_Prod_Merc_Long_Other", "Traders_Prod_Merc_Short_Other",
# "Traders_Swap_Long_Other",      "Traders_Swap_Short_Other",      "Traders_Swap_Spread_Other",
# "Traders_M_Money_Long_Other",   "Traders_M_Money_Short_Other",   "Traders_M_Money_Spread_Other",
# "Traders_Other_Rept_Long_Other","Traders_Other_Rept_Short_Other", "Traders_Other_Rept_Spread_Other",
# "Traders_Tot_Rept_Long_Other",  "Traders_Tot_Rept_Short_Other",
# "Conc_Gross_LE_4_TDR_Long_All", "Conc_Gross_LE_4_TDR_Short_All",
# "Conc_Gross_LE_8_TDR_Long_All", "Conc_Gross_LE_8_TDR_Short_All",
# "Conc_Net_LE_4_TDR_Long_All",   "Conc_Net_LE_4_TDR_Short_All",
# "Conc_Net_LE_8_TDR_Long_All",   "Conc_Net_LE_8_TDR_Short_All",
# "Conc_Gross_LE_4_TDR_Long_Old", "Conc_Gross_LE_4_TDR_Short_Old",
# "Conc_Gross_LE_8_TDR_Long_Old", "Conc_Gross_LE_8_TDR_Short_Old",
# "Conc_Net_LE_4_TDR_Long_Old",   "Conc_Net_LE_4_TDR_Short_Old",
# "Conc_Net_LE_8_TDR_Long_Old",   "Conc_Net_LE_8_TDR_Short_Old",
# "Conc_Gross_LE_4_TDR_Long_Other","Conc_Gross_LE_4_TDR_Short_Other",
# "Conc_Gross_LE_8_TDR_Long_Other","Conc_Gross_LE_8_TDR_Short_Other",
# "Conc_Net_LE_4_TDR_Long_Other",  "Conc_Net_LE_4_TDR_Short_Other",
# "Conc_Net_LE_8_TDR_Long_Other",  "Conc_Net_LE_8_TDR_Short_Other",
# "Contract_Units",
# "CFTC_Contract_Market_Code_Quotes","CFTC_Market_Code_Quotes",
# "CFTC_Commodity_Code_Quotes",
# "CFTC_SubGroup_Code",
# "FutOnly_or_Combined"

#
# positional arguments:
#   infile                Filename of CSV input file
#   index_var             Name of column for time axis, i.e. dates, year and week etc.
#   id_var                Column identifying a row, typically symbol/ticker
#   value_vars            Columns with values, for instance Open,High,Low,Close,Volume etc.
#   outfile               Filename of parquet to create
#

FOLDER=$COTFOLDER/fut-disagg
FILE=f_year.txt

FILES=""
for i in $(seq $FROM_YEAR $TO_YEAR); do
  FILES="${FOLDER}/${i}/${FILE},$FILES"
done

echo "input files:$FILES"
python3 -m tsl.create --YearWeek --no-use_ffill --date_format '%y%m%d' \
			 --save_summary disagg --backends $TSLBACKEND --dbname $TSLDBNAME \
                         --col_names OpenInterest,ProdMerc_Long,ProdMerc_Short,Swap_Long,Swap_Short,MMoney_Long,MMoney_Short,OtherRept_Long,OtherRept_Short,NonRept_Short,NonRept_Long\
			 $TSLDBFOLDER \
                         $FILES  \
			 As_of_Date_In_Form_YYMMDD \
			 CFTC_Contract_Market_Code \
                         Open_Interest_All,Prod_Merc_Positions_Long_All,Prod_Merc_Positions_Short_All,Swap_Positions_Long_All,Swap__Positions_Short_All,M_Money_Positions_Long_All,M_Money_Positions_Short_All,Other_Rept_Positions_Long_All,Other_Rept_Positions_Short_All,NonRept_Positions_Long_All,NonRept_Positions_Short_All \
                         ${DA_OUTFILE}_da



#
# Financial
# --------
#
#
# "Market_and_Exchange_Names"
# "As_of_Date_In_Form_YYMMDD","Report_Date_as_YYYY-MM-DD"
# "CFTC_Contract_Market_Code",
# "CFTC_Market_Code",
# "CFTC_Region_Code",
# "CFTC_Commodity_Code",
# "Open_Interest_All",
# "Dealer_Positions_Long_All","Dealer_Positions_Short_All","Dealer_Positions_Spread_All",
# "Asset_Mgr_Positions_Long_All","Asset_Mgr_Positions_Short_All","Asset_Mgr_Positions_Spread_All",
# "Lev_Money_Positions_Long_All","Lev_Money_Positions_Short_All","Lev_Money_Positions_Spread_All",
# "Other_Rept_Positions_Long_All","Other_Rept_Positions_Short_All","Other_Rept_Positions_Spread_All",
# "Tot_Rept_Positions_Long_All","Tot_Rept_Positions_Short_All",
# "NonRept_Positions_Long_All","NonRept_Positions_Short_All",
# "Change_in_Open_Interest_All",
# "Change_in_Dealer_Long_All","Change_in_Dealer_Short_All","Change_in_Dealer_Spread_All",
# "Change_in_Asset_Mgr_Long_All","Change_in_Asset_Mgr_Short_All","Change_in_Asset_Mgr_Spread_All",
# "Change_in_Lev_Money_Long_All","Change_in_Lev_Money_Short_All","Change_in_Lev_Money_Spread_All",
# "Change_in_Other_Rept_Long_All","Change_in_Other_Rept_Short_All","Change_in_Other_Rept_Spread_All",
# "Change_in_Tot_Rept_Long_All","Change_in_Tot_Rept_Short_All",
# "Change_in_NonRept_Long_All","Change_in_NonRept_Short_All",
# "Pct_of_Open_Interest_All",
# "Pct_of_OI_Dealer_Long_All","Pct_of_OI_Dealer_Short_All","Pct_of_OI_Dealer_Spread_All",
# "Pct_of_OI_Asset_Mgr_Long_All","Pct_of_OI_Asset_Mgr_Short_All","Pct_of_OI_Asset_Mgr_Spread_All",
# "Pct_of_OI_Lev_Money_Long_All","Pct_of_OI_Lev_Money_Short_All","Pct_of_OI_Lev_Money_Spread_All",
# "Pct_of_OI_Other_Rept_Long_All","Pct_of_OI_Other_Rept_Short_All","Pct_of_OI_Other_Rept_Spread_All",
# "Pct_of_OI_Tot_Rept_Long_All","Pct_of_OI_Tot_Rept_Short_All",
# "Pct_of_OI_NonRept_Long_All","Pct_of_OI_NonRept_Short_All",
# "Traders_Tot_All",
# "Traders_Dealer_Long_All","Traders_Dealer_Short_All","Traders_Dealer_Spread_All",
# "Traders_Asset_Mgr_Long_All","Traders_Asset_Mgr_Short_All","Traders_Asset_Mgr_Spread_All",
# "Traders_Lev_Money_Long_All","Traders_Lev_Money_Short_All","Traders_Lev_Money_Spread_All",
# "Traders_Other_Rept_Long_All","Traders_Other_Rept_Short_All","Traders_Other_Rept_Spread_All",
# "Traders_Tot_Rept_Long_All","Traders_Tot_Rept_Short_All",
# "Conc_Gross_LE_4_TDR_Long_All","Conc_Gross_LE_4_TDR_Short_All",
# "Conc_Gross_LE_8_TDR_Long_All","Conc_Gross_LE_8_TDR_Short_All",
# "Conc_Net_LE_4_TDR_Long_All","Conc_Net_LE_4_TDR_Short_All",
# "Conc_Net_LE_8_TDR_Long_All","Conc_Net_LE_8_TDR_Short_All",
# "Contract_Units",
# "CFTC_Contract_Market_Code_Quotes",
# "CFTC_Market_Code_Quotes",
# "CFTC_Commodity_Code_Quotes",
# "CFTC_SubGroup_Code","FutOnly_or_Combined"args.header.split(',')

FOLDER=$COTFOLDER/fut-fin
FILE=FinFutYY.txt

FILES=""
for i in $(seq $FROM_YEAR $TO_YEAR); do
  FILES="${FOLDER}/${i}/${FILE},$FILES"
done

echo "input files:$FILES"
python3 -m tsl.create --YearWeek --no-use_ffill --date_format '%y%m%d' \
			 --save_summary fin --backends $TSLBACKEND --dbname $TSLDBNAME \
                         --col_names OpenInterest,Dealer_Long,Dealer_Short,AssetMgr_Long,AssetMgr_Short,LevMoney_Long,LevMoney_Short,OtherRept_Long,OtherRept_Short,NonRept_Long,NonRept_Short \
			 $TSLDBFOLDER \
                         $FILES \
			 As_of_Date_In_Form_YYMMDD \
                         CFTC_Contract_Market_Code \
                         Open_Interest_All,Dealer_Positions_Long_All,Dealer_Positions_Short_All,Asset_Mgr_Positions_Long_All,Asset_Mgr_Positions_Short_All,Lev_Money_Positions_Long_All,Lev_Money_Positions_Short_All,Other_Rept_Positions_Long_All,Other_Rept_Positions_Short_All,NonRept_Positions_Long_All,NonRept_Positions_Short_All \
                         ${DA_OUTFILE}_fin


# Merge disagg and fin and add _Net column
# ----------------------------------------

python3 -m tsl.merge $TSLDBFOLDER ${DA_OUTFILE}_da ${DA_OUTFILE}_fin ${DA_OUTFILE} --index YearWeek --no-cmp-tickers --backend $TSLBACKEND --dbname $TSLDBNAME

arg="VMMoney_Net=VMMoney_Long-VMMoney_Short; VNonRept_Net=VNonRept_Long-VNonRept_Short; VOtherRept_Net=VOtherRept_Long-VOtherRept_Short; VProdMerc_Net=VProdMerc_Long-VProdMerc_Short"
arg="$arg; VSwap_Net=VSwap_Long-VSwap_Short;VAssetMgr_Net=VAssetMgr_Long-VAssetMgr_Short; VDealer_Net=VDealer_Long-VDealer_Short; VLevMoney_Net=VLevMoney_Long-VLevMoney_Short"   
python3 -m tsl.expr "$arg" $TSLDBFOLDER $DA_OUTFILE $DA_OUTFILE --backend $TSLBACKEND --dbname $TSLDBNAME


# Legacy version
# ==============

# "Market and Exchange Names",
# "As of Date in Form YYMMDD","As of Date in Form YYYY-MM-DD",
# "CFTC Contract Market Code",
# "CFTC Market Code in Initials",
# "CFTC Region Code","CFTC Commodity Code",
# "Open Interest (All)",
# "Noncommercial Positions-Long (All)","Noncommercial Positions-Short (All)","Noncommercial Positions-Spreading (All)",
# "Commercial Positions-Long (All)","Commercial Positions-Short (All)",
# " Total Reportable Positions-Long (All)","Total Reportable Positions-Short (All)",
# "Nonreportable Positions-Long (All)","Nonreportable Positions-Short (All)",
# "Open Interest (Old)",
# "Noncommercial Positions-Long (Old)","Noncommercial Positions-Short (Old)","Noncommercial Positions-Spreading (Old)",
# "Commercial Positions-Long (Old)","Commercial Positions-Short (Old)",
# "Total Reportable Positions-Long (Old)","Total Reportable Positions-Short (Old)",
# "Nonreportable Positions-Long (Old)","Nonreportable Positions-Short (Old)",
# "Open Interest (Other)",
# "Noncommercial Positions-Long (Other)","Noncommercial Positions-Short (Other)","Noncommercial Positions-Spreading (Other)",
# "Commercial Positions-Long (Other)","Commercial Positions-Short (Other)",
# "Total Reportable Positions-Long (Other)","Total Reportable Positions-Short (Other)",
# "Nonreportable Positions-Long (Other)","Nonreportable Positions-Short (Other)",
# "Change in Open Interest (All)",
# "Change in Noncommercial-Long (All)","Change in Noncommercial-Short (All)","Change in Noncommercial-Spreading (All)",
# "Change in Commercial-Long (All)","Change in Commercial-Short (All)",
# "Change in Total Reportable-Long (All)","Change in Total Reportable-Short (All)",
# "Change in Nonreportable-Long (All)","Change in Nonreportable-Short (All)",
# "% of Open Interest (OI) (All)",
# "% of OI-Noncommercial-Long (All)","% of OI-Noncommercial-Short (All)","% of OI-Noncommercial-Spreading (All)",
# "% of OI-Commercial-Long (All)","% of OI-Commercial-Short (All)",
# "% of OI-Total Reportable-Long (All)","% of OI-Total Reportable-Short (All)",
# "% of OI-Nonreportable-Long (All)","% of OI-Nonreportable-Short (All)",
# "% of Open Interest (OI)(Old)",
# "% of OI-Noncommercial-Long (Old)","% of OI-Noncommercial-Short (Old)","% of OI-Noncommercial-Spreading (Old)",
# "% of OI-Commercial-Long (Old)","% of OI-Commercial-Short (Old)",
# "% of OI-Total Reportable-Long (Old)","% of OI-Total Reportable-Short (Old)",
# "% of OI-Nonreportable-Long (Old)","% of OI-Nonreportable-Short (Old)",
# "% of Open Interest (OI) (Other)",
# "% of OI-Noncommercial-Long (Other)","% of OI-Noncommercial-Short (Other)","% of OI-Noncommercial-Spreading (Other)",
# "% of OI-Commercial-Long (Other)","% of OI-Commercial-Short (Other)",
# "% of OI-Total Reportable-Long (Other)","% of OI-Total Reportable-Short (Other)",
# "% of OI-Nonreportable-Long (Other)","% of OI-Nonreportable-Short (Other)",
# "Traders-Total (All)",
# "Traders-Noncommercial-Long (All)","Traders-Noncommercial-Short (All)","Traders-Noncommercial-Spreading (All)",
# "Traders-Commercial-Long (All)","Traders-Commercial-Short (All)",
# "Traders-Total Reportable-Long (All)","Traders-Total Reportable-Short (All)",
# "Traders-Total (Old)",
# "Traders-Noncommercial-Long (Old)","Traders-Noncommercial-Short (Old)","Traders-Noncommercial-Spreading (Old)",
# "Traders-Commercial-Long (Old)","Traders-Commercial-Short (Old)",
# "Traders-Total Reportable-Long (Old)","Traders-Total Reportable-Short (Old)",
# "Traders-Total (Other)",
# "Traders-Noncommercial-Long (Other)","Traders-Noncommercial-Short (Other)","Traders-Noncommercial-Spreading (Other)",
# "Traders-Commercial-Long (Other)","Traders-Commercial-Short (Other)",
# "Traders-Total Reportable-Long (Other)","Traders-Total Reportable-Short (Other)",
# "Concentration-Gross LT =4 TDR-Long (All)","Concentration-Gross LT =4 TDR-Short (All)",
# "Concentration-Gross LT =8 TDR-Long (All)","Concentration-Gross LT =8 TDR-Short (All)",
# "Concentration-Net LT =4 TDR-Long (All)","Concentration-Net LT =4 TDR-Short (All)",
# "Concentration-Net LT =8 TDR-Long (All)","Concentration-Net LT =8 TDR-Short (All)",
# "Concentration-Gross LT =4 TDR-Long (Old)","Concentration-Gross LT =4 TDR-Short (Old)",
# "Concentration-Gross LT =8 TDR-Long (Old)","Concentration-Gross LT =8 TDR-Short (Old)",
# "Concentration-Net LT =4 TDR-Long (Old)","Concentration-Net LT =4 TDR-Short (Old)",
# "Concentration-Net LT =8 TDR-Long (Old)","Concentration-Net LT =8 TDR-Short (Old)",
# "Concentration-Gross LT =4 TDR-Long (Other)","Concentration-Gross LT =4 TDR-Short(Other)",
# "Concentration-Gross LT =8 TDR-Long (Other)","Concentration-Gross LT =8 TDR-Short(Other)",
# "Concentration-Net LT =4 TDR-Long (Other)","Concentration-Net LT =4 TDR-Short (Other)",
# "Concentration-Net LT =8 TDR-Long (Other)","Concentration-Net LT =8 TDR-Short (Other)",
# "Contract Units",
# "CFTC Contract Market Code (Quotes)",
# "CFTC Market Code in Initials (Quotes)",
# "CFTC Commodity Code (Quotes)"

FOLDER=$COTFOLDER/fut-dea
FILE=annual.txt

# Replace spaces in header with underscoere
f() {
  head -n 1 $1 | tr ' ' '_' | tr -d '"()'  > $2
  tail -n+2 $1 >> $2
}

FILES=""
rm -rf $TMPFOLDER
for i in $(seq $FROM_YEAR $TO_YEAR); do
  mkdir -p "${TMPFOLDER}/${i}"
  f "${FOLDER}/${i}/${FILE}" "${TMPFOLDER}/${i}/${FILE}"
  FILES="${TMPFOLDER}/${i}/${FILE},$FILES"
done


echo "input files:$FILES"
python3 -m tsl.create \
                         --YearWeek --no-use_ffill --date_format '%y%m%d' \
			 --save_summary dea --backends $TSLBACKEND --dbname $TSLDBNAME \
                         --col_names OpenInterest,NonComm_Long,NonComm_Short,Comm_Long,Comm_Short,NonRept_Long,NonRept_Short \
			 $TSLDBFOLDER \
                         $FILES \
                         As_of_Date_in_Form_YYMMDD \
                         CFTC_Contract_Market_Code \
                         Open_Interest_All,Noncommercial_Positions-Long_All,Noncommercial_Positions-Short_All,Commercial_Positions-Long_All,Commercial_Positions-Short_All,Nonreportable_Positions-Long_All,Nonreportable_Positions-Short_All \
                         $LEGACY_OUTFILE


arg="VComm_Net=VComm_Long-VComm_Short; VNonComm_Net=VNonComm_Long-VNonComm_Short; VNonRept_Net=VNonRept_Long-VNonRept_Short"
python3 -m tsl.expr "$arg" $TSLDBFOLDER $LEGACY_OUTFILE $LEGACY_OUTFILE --backend $TSLBACKEND
