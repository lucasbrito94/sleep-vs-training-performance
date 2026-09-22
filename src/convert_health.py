# src/convert_health.py
import xml.etree.ElementTree as ET
import pandas as pd
from datetime import datetime
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]
XML_CANDIDATES = [
    BASE / "data" / "raw" / "exportar.xml",
    BASE / "data" / "raw" / "export.xml",
    BASE / "data" / "raw" / "export_cda.xml"
]
OUTPATH = BASE / "data" / "processed" / "health_metrics.csv"

def find_xml():
    for p in XML_CANDIDATES:
        if p.exists():
            return p
    raise FileNotFoundError(f"Nenhum export.xml encontrado em: {XML_CANDIDATES}")

def parse_health(xml_path):
    print(f"Parsing XML: {xml_path}")
    tree = ET.parse(xml_path)
    root = tree.getroot()
    records = []
    # Records are <Record ... /> and SleepAnalysis may be <Record type="HKCategoryTypeIdentifierSleepAnalysis" .../>
    for record in root.findall('Record'):
        rtype = record.get('type') or ""
        start = record.get('startDate')
        end = record.get('endDate')
        value = record.get('value')
        source = record.get('sourceName')
        # We capture common types that contain useful metrics
        if any(key in rtype for key in ['SleepAnalysis','heartRateVariability','restingHeartRate','stepCount','activeEnergyBurned','bodyMass','dietaryCaffeine']):
            records.append({
                'type': rtype,
                'start': start,
                'end': end,
                'value': value,
                'source': source
            })
    return pd.DataFrame(records)

def normalize(df):
    rows = []
    for _, r in df.iterrows():
        t = r['type']
        start = pd.to_datetime(r['start'])
        end = pd.to_datetime(r['end']) if r['end'] else None
        date = start.date()
        if 'SleepAnalysis' in t:
            # convert sleeping interval to hours (end-start)
            if end is not None:
                hours = (end - start).total_seconds() / 3600.0
                # Some records indicate 'InBed' vs 'Asleep' in the 'value' field; we aggregate total hours per day
                rows.append({'date': date, 'metric': 'sleep_hours', 'value': hours})
        elif 'heartRateVariability' in t:
            try:
                rows.append({'date': date, 'metric': 'hrv', 'value': float(r['value'])})
            except:
                continue
        elif 'restingHeartRate' in t:
            try:
                rows.append({'date': date, 'metric': 'resting_hr', 'value': float(r['value'])})
            except:
                continue
        elif 'stepCount' in t:
            try:
                rows.append({'date': date, 'metric': 'steps', 'value': float(r['value'])})
            except:
                continue
        elif 'activeEnergyBurned' in t:
            try:
                rows.append({'date': date, 'metric': 'active_calories', 'value': float(r['value'])})
            except:
                continue
        elif 'bodyMass' in t:
            try:
                rows.append({'date': date, 'metric': 'weight', 'value': float(r['value'])})
            except:
                continue
        elif 'dietaryCaffeine' in t:
            try:
                rows.append({'date': date, 'metric': 'caffeine_mg', 'value': float(r['value'])})
            except:
                continue

    if not rows:
        print("Nenhuma linha extraída — verifique se o XML contém as medições esperadas.")
        return pd.DataFrame()

    rdf = pd.DataFrame(rows)
    # pivot to wide, summing numeric values per day where appropriate
    wide = rdf.pivot_table(index='date', columns='metric', values='value', aggfunc='sum').reset_index()
    wide['date'] = pd.to_datetime(wide['date'])
    return wide

def main():
    xml_path = find_xml()
    df = parse_health(xml_path)
    wide = normalize(df)
    if wide.empty:
        print("Dataframe resultante vazio. Cheque o XML ou cole aqui as primeiras linhas para eu ajustar o parser.")
        return
    OUTPATH.parent.mkdir(parents=True, exist_ok=True)
    wide.to_csv(OUTPATH, index=False)
    print(f"Arquivo exportado: {OUTPATH}")
    print(wide.head(10).to_string(index=False))

if __name__ == '__main__':
    main()
