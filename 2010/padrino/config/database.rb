Sequel::Model.plugin(:schema)
DB = case Padrino.env
  when :development then Sequel.connect("sqlite://" + Padrino.root('db', "demo.db"),  :loggers => [logger])
  when :production  then Sequel.connect("sqlite://" + Padrino.root('db', "demo.db"),  :loggers => [logger])
  when :test        then Sequel.connect("sqlite://" + Padrino.root('db', "test.db"),  :loggers => [logger])
end
