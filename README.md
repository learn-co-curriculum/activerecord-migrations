# ActiveRecord Migrations

## Objectives

1. Understand what migrations are and what they are used for.
2. Learn how to create, modify and delete a table and columns in a table.
3. Learn how to use Rake.

### Creating Migrations

Migrations are a convenient way for you to alter your database in a structured and organized manner. You could edit fragments of SQL by hand but you would then be responsible for telling other developers that they need to go and run them. You’d also have to keep track of which changes need to be run against the production machines next time you deploy.

Migrations also allow you to describe these transformations using Ruby. The great thing about this is that it is database independent: you don’t need to worry about the precise syntax of CREATE TABLE any more than you worry about variations on SELECT * (you can drop down to raw SQL for database specific features). For example, you could use SQLite3 during development, but Postgres in production.

Another way to think of migrations is like version control for your database. You might create a table, add some data to it, and then make some changes to it later on. By adding a new migration for each change you make to the database, you won't lose any data you don't want to, and you can easily revert changes.

Executed migrations are tracked by ActiveRecord in your database, so they aren't used twice. Using the migrations system to apply the schema changes is easier than keeping track of the changes manually and executing them manually at the appropriate time.

We will write our migrations in a file called `01_create_cats.rb` in the `db/migrate` directory (we'll talk about why we added the 01 later).

```ruby
# db/migrate/01_create_cats.rb

class CreateCats < ActiveRecord::Migration
  def up
  end

  def down
  end
end
```

Here we're creating a class called `CreateCats` which inherits from ActiveRecord's `ActiveRecord::Migration` module. Within the class we have an `up` method to define what code to execute when the migration is run, and in the `down` method we define what code to execute when the migration is rolled back. Think of it like "do" and "undo."

Another method is available to use besides `up` and `down`: `change`, which is more common for basic migrations.

```ruby
# db/migrate/01_create_cats.rb

class CreateCats < ActiveRecord::Migration
  def change
  end
end

```

Which is just short for do this, and then undo it on rollback. Let's look at creating the rest of the migration to generate our cats table and add some columns.

```ruby
# db/migrate/01_create_cats.rb

class CreateCats < ActiveRecord::Migration
  def up
    create_table :cats do |t|
      t.string :name
      t.integer :age
      t.integer :breed
    end
  end

  def down
    drop_table :cats
  end
end
```

Here we've added the create_table method, and passed the name of the table we want to create as a symbol. To add columns to our table, we will give the data type on the left and on the right we will write the name we'd like to give our column. The only thing that we're missing is the primary key. ActiveRecord will generate that column for us, and for each row added, a key will be auto incremented.



## Using migrations to manipulate existing tables

Here is another place where migrations really shine. Let's add a gender column to our cats table. Remember that ActiveRecord keeps track of what migrations we've already run, so adding it to our 01_create_cats.rb won't work because it won't get executed when we run our migrations again, unless we drop our entire table before rerunning the migration. But that isn't best practices, especially with a production database.

To make this change we're going to need a new migration, which we'll call `02_add_gender_to_cats.rb`.

```ruby
# db/migrate/02_add_gender_to_cats.rb

class AddGenderToCats < ActiveRecord::Migration
  def up
    add_column :cats, :gender, :string
  end
  
  def down
    remove_column :cats, :gender 
  end
end
```

Pretty awesome, right? We basically just told ActiveRecord to add a column to the artists table, call it gender, and it's going to be a string.

Notice how we incremented the number in the file name there? Imagine for a minute that you deleted your original database and wanted to execute the migrations again. ActiveRecord is going to execute each file, but it has to do so in some order and it happens to do that in alpha-numerical order. If we didn't have the numbers, our add_column migration would have tried to run first ('a' comes before 'c') and our artists table wouldn't have even been created yet! So we used some numbers to make sure they execute in order. In reality our two-digit system is very rudimentary. As you'll see later on, frameworks like rails have generators that create migrations with very accurate timestamps so you'll never have that problem.

Now that you've save the migration, back to the terminal to run it:

`rake db:migrate`

Awesome! Now go back to the console: `rake console`

and check it out:

```ruby
Artist.column_names
#=> ["id", "name", "genre", "age", "hometown", "gender"]
```

Great!

Nope- wait. Word just came down from the boss- you weren't supposed to ship that change yet! OH NO! No worries, we'll rollback to the first migration.

Run `rake -T`. Which command should we use?

`rake db:rollback`

Then double check:


```ruby
Artist.column_names
#=> ["id", "name", "genre", "age", "hometown"]
```

Oh good, your job is saved. Thanks ActiveRecord! Now when the boss says it's actually time to add that column, you can just run it again!

`rake db:migrate`











### Running Migrations

The simplest way to run our migrations is with ActiveRecord's through a raketask that we're given through the activerecord gem. By running `rake -T` we can access these.

The way in which we get these commands as raketasks is through `require 'sinatra/activerecord/rake'` in our `Rakefile`.

If you take a look at `environment.rb`, which our Rakefile also requires, you'll see:

```ruby
require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/artists.sqlite"
)
```

This file is requiring the gems in our Gemfile and giving our program access to them. We're going to connect to our cats db, which will be created in the migration, via sqlite3 (the adapter).

Before we run  `rake db:migrate`

4) Take a look at `cat.rb`. Let's create an Cat class.

```ruby
# cat.rb

class Cat
end
```

Next, we'll extend the class with `ActiveRecord::Base`

```ruby
# cat.rb

class Cat < ActiveRecord::Base
end
```

To test it out, let's use the raketask `rake console`, which we're created in the `Rakefile`.

