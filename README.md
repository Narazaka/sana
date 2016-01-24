# [Sana](https://github.com/Narazaka/sana)

[![Gem](https://img.shields.io/gem/v/sana.svg)](https://rubygems.org/gems/sana)
[![Gem](https://img.shields.io/gem/dtv/sana.svg)](https://rubygems.org/gems/sana)
[![Gemnasium](https://gemnasium.com/Narazaka/sana.svg)](https://gemnasium.com/Narazaka/sana)
[![Inch CI](http://inch-ci.org/github/Narazaka/sana.svg)](http://inch-ci.org/github/Narazaka/sana)
[![Build Status](https://travis-ci.org/Narazaka/sana.svg)](https://travis-ci.org/Narazaka/sana)
[![codecov.io](https://codecov.io/github/Narazaka/sana/coverage.svg?branch=master)](https://codecov.io/github/Narazaka/sana?branch=master)
[![Code Climate](https://codeclimate.com/github/Narazaka/sana/badges/gpa.svg)](https://codeclimate.com/github/Narazaka/sana)

Ukagaka SHIORI subsystem 'Sana'

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sana'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sana

## Usage

Example of basic SHIORI subsystem with SHIOLINK.DLL protocol.

make main.rb like below...

```ruby
require 'sana'
require 'shiolink'
require 'json'

def _load(dirpath)
  if File.exist?("save.json")
    $save = JSON.parse(File.read("save.json"))
  else
    $save = {}
  end
end

def _unload
  File.write("save.json", JSON.dump($save))
  exit
end

def version r; '0.0.1'; end
def name r; 'Sana'; end
def craftman r; 'Narazaka'; end
def craftmanw r; '奈良阪'; end

def OnBoot r
  unless $save['boot_count']
    $save['boot_count'] = 1
  else
    $save['boot_count'] += 1
  end
  '\h\s[0]おはよう。\w9\u\s[10]こんばんは。\e'
end

def OnClose r
  if r.Reference0 == 'user'
    '\h\s[0]またね。\w9\-'
  else
    '\h\s[0]おわー！？\w9\-'
  end
end

include Sana::ResponseHelper

sana = Sana.new
shiolink = Shiolink.new(sana.method(:load), sana.method(:unload), sana.method(:request))
shiolink.start
```

then...

```
ruby main.rb
```

or make SHIOLINK.INI and run with any basewares...

```
[SHIOLINK]
commandline = ruby ./main.rb

charmode  = UTF-8
```

## API

[API Document](http://www.rubydoc.info/github/Narazaka/sana)

## License

This is released under [MIT License](http://narazaka.net/license/MIT?2016).
