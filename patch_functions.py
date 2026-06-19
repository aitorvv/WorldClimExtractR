with open("scripts/functions.r", "r") as f:
    content = f.read()

# Rename the function and path
content = content.replace("get_wc_historical_monthly_data", "get_wc_historical_monthly_weather_data")
content = content.replace('file.path(basedir, "historical_monthly_data")', 'file.path(basedir, "historical_monthly_weather_data")')

with open("scripts/functions.r", "w") as f:
    f.write(content)

with open("scripts/main.r", "r") as f:
    content = f.read()

content = content.replace("get_wc_historical_monthly_data", "get_wc_historical_monthly_weather_data")

with open("scripts/main.r", "w") as f:
    f.write(content)
