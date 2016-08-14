REPOSITORY = 'emacs-jp/reading-init.el'
MASTER_REPOSITORY = if ENV['GH_TOKEN']
    "https://$GH_TOKEN@github.com/#{REPOSITORY}"
  else
    "git@github.com:#{REPOSITORY}.git"
  end
PUBLISH_BRANCH = 'gh-pages'
DEST_DIR = 'build'

def initialize_repository(repository, branch)
  require 'fileutils'

  if Dir["#{DEST_DIR}/.git"].empty?
    FileUtils.rm_rf DEST_DIR
    sh "git clone --quiet #{repository} #{DEST_DIR} 2> /dev/null"
  end

  Dir.chdir DEST_DIR do
    sh "git checkout --orphan #{branch}"
  end
end

def update_repository(branch)
  Dir.chdir DEST_DIR do
    sh 'git fetch origin'
    sh "git reset --hard origin/#{branch}"
    sh 'git clean -fd'
  end
end

def build
  sh 'bundle exec middleman build'
end

def server
  begin
    sh "bundle exec middleman server"
  rescue Interrupt
    sleep 3
  end
end

def clean
  require 'fileutils'

  Dir["#{DEST_DIR}/*"].each do |file|
    FileUtils.rm_rf file
  end
end

def push_to_gh_pages(repository, branch)
  sha1, _ = `git log -n 1 --oneline`.strip.split(' ')

  Dir.chdir DEST_DIR do
    sh 'git add -A'
    sh "git commit -m 'Update with #{sha1}'"
    sh "git push -f --quiet #{repository} #{branch} 2> /dev/null"
  end
end

desc 'Setup origin repository for GitHub pages'
task :setup do
  initialize_repository MASTER_REPOSITORY, PUBLISH_BRANCH
#  update_repository PUBLISH_BRANCH
end

desc 'Clean built files'
task :clean do
  clean
end

desc 'Build sites'
task :build do
  clean
  build
end

desc 'Deploy website'
task :server do
  build
  server
end

desc 'Publish website'
task :publish do
  push_to_gh_pages MASTER_REPOSITORY, PUBLISH_BRANCH
end
