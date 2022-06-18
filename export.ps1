$app_name = "pee-aitch-pee"

cd client

godot_v3.2.3 --export "HTML5" ../linux/client/index.html

cd ../server
godot_v3.2.3 --export-pack "Linux/X11" ../linux/server/server.pck

cd ../linux

heroku container:login
heroku container:push web --app "$app_name"
heroku container:release web --app "$app_name"
heroku open -a "$app_name"
