set -o errexit

indent() {
  sed -u 's/^/       /'
}

echo "-----> Installing yt-dlp"
cd $1
mkdir -p "vendor"
cd "vendor"
mkdir -p ./yt-dlp/bin/
cd ./yt-dlp/bin/
wget $(curl -s https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest \
| grep -e "browser_download_url.*yt-dlp" \
| cut -d : -f 2,3 \
| tr -d \" \
| grep -e "yt-dlp$")
chmod a+rx yt-dlp
echo "Adding to PATH" | indent
PROFILE="$1/.profile.d/yt-dlp.sh"
mkdir -p "$1/.profile.d/"
touch $PROFILE
echo 'export PATH="$PATH:$HOME/vendor/yt-dlp/bin"' >> $PROFILE

bundle install

bundle exec rake assets:precompile

bundle exec rake assets:clean

bundle exec rake db:migrate
