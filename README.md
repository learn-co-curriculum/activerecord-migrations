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

Code along: 

1. Let's start with creating a directory called `db`. Within the `db` directory, create a `migrate` directory.
2. In the `migrate` directory, create a file called `01_create_animals.rb` (we'll talk about why we added the 01 later).

```ruby
# db/migrate/01_create_animals.rb

class CreateAnimals < ActiveRecord::Migration
  def up
  end

  def down
  end
end
```

Here we're creating a class called `CreateAnimals` which inherits from ActiveRecord's `ActiveRecord::Migration` module. Within the class we have an `up` method to define what code to execute when the migration is run, and in the `down` method we define what code to execute when the migration is rolled back. Think of it like "do" and "undo."


Another method is available to use besides `up` and `down`: `change`, which is more common for basic migrations. Our `CreateAnimals`migration would look like this, if we used the `change` method.

```ruby
# db/migrate/01_create_animals.rb

class CreateAnimals < ActiveRecord::Migration
  def change
  end
end

```

Which is just short for "do this, and then undo it on rollback". Let's look at creating the rest of the migration to generate our animals table and add some columns.

```ruby
# db/migrate/01_create_animals.rb

class CreateAnimals < ActiveRecord::Migration
  def up
    create_table :animals do |t|
      t.string :name
      t.integer :age
      t.integer :breed
    end
  end

  def down
    drop_table :animals
  end
end
```

Here we've added the create_table method into our `up` method, and passed the name of the table we want to create as a symbol.

**NOTE:** Naming files and classes correctly is very important. Use the following naming conventions when using ActiveRecord:


| Type            | Example                   |
|-------          | ----                      |
| Class file      | `Animal.rb`               |
| Class           | `class Animal`            |
| Table           | `create_table :animals `  | 
| Migration       | `01_create_animals.rb`    |
| Migration Class | `class CreateAnimals`     |

To add columns to our table, we use ActiveRecord's DSL iterator and use `t` (by convention) as a placeholder variable for the table. For each column, we then write `t.data_type column_name`, substituting the data type on the left and column name on the right. The only thing that we're missing is the primary key. 

Luckily, ActiveRecord will take care of this for us by generating the primary key column for us. For each new row added to our table, a key will be auto incremented.

### Running Migrations using Rake Tasks

The simplest way to run our migrations is by using a Rake task that we're given through the ActiveRecord gem. How do we access these?

Run `rake -T` to see the list of commands we have. (before running `rake -T`, make sure we run `bundle install`). It should look like this:

![Rake Tasks](https://curriculum-content.s3.amazonaws.com/web-development/Sinatra/raketasks.png)

Where do these commands come from? Let's look at our `Rakefile` (in the root of the project). The way in which we get these commands as Rake tasks is through `require 'sinatra/activerecord/rake'`.

Now take a look at `environment.rb`, which our Rakefile also requires:

```ruby
require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/animals.sqlite"
)
```

This file is requiring the gems in our Gemfile and giving our program access to them. We're going to connect to our animals db, which will be created in the migration, via sqlite3 (the adapter).

In the console, run `rake db:migrate`

![migration](https://curriculum-content.s3.amazonaws.com/web-development/Sinatra/migration.png)

When you run rake `db:migrate`, the ActiveRecord migration is being converted in to SQL commands which are then fired against the database.

Take a look at `animal.rb`. Let's create an Animal class.

```ruby
# animal.rb

class Animal
end
```

Next, we'll extend the class with `ActiveRecord::Base`. This is very important, because it provides the link between the Animal class and the Animals table that we've built using ActiveRecord migrations.

```ruby
# animal.rb

class Animal < ActiveRecord::Base
end
```



To test it out, let's use the raketask `rake console`, which we're created in the `Rakefile`.


### Try out the following:

View that the class exists:

```ruby
Animal
#=> Animal (call 'Animal.connection' to establish a connection)
```

View that database columns:

```ruby
Animal.column_names
#=> ["id", "name", "age", "breed"]
```

Instantiate a new Animal named Maru, set her age to 3, save her to the database:

```ruby
maru = Animal.new(name: "Maru")
#=> #<Animal id: nil, name: "Maru", age: nil, breed: nil>


a.age = 30
#=> 30

a.save
#=> true
```

The `.new` method creates a new instance in memory, be in order for that instance to persist, we need to save it. If we want to create a new instance and save it all in on go, we can use `.create`.

```ruby
Animal.create(name: "Hana", age: 1)
#=> #<Animal id: 2, name: "Hana", age: 1, breed: nil>
```

Return an array of all Animals from the database:

```ruby
Animal.all
=> [#<Animal id: 1, name: "Maru", age: 3, breed: nil>,
 #<Animal id: 2, name: "Hana", age: 1, breed: nil>]
```

Find an Animal by name:

```ruby
Animal.find_by(name: 'Hana')
#=> #<Animal id: 2, name: "Hana", age: 1, breed: nil>
```

There are a number of methods you can now use to create, retrieve, update, and delete data from your database, and a whole lot more.

Take a look at these [CRUD methods](http://guides.rubyonrails.org/active_record_basics.html#crud-reading-and-writing-data) here.


## Using migrations to manipulate existing tables

Here is another place where migrations really shine. Let's add a gender column to our animals table. Remember that ActiveRecord keeps track of what migrations we've already run, so adding it to our 01_create_animals.rb won't work because it won't get executed when we run our migrations again without dropping our entire table before rerunning the migration. But that isn't best practice, especially with a production database.

To make this change we're going to need a new migration, which we'll call `02_add_gender_to_animals.rb`.

```ruby
# db/migrate/02_add_gender_to_animals.rb

class AddGenderToAnimals < ActiveRecord::Migration
  def up
    add_column :animals, :gender, :string
  end
  
  def down
    remove_column :animals, :gender 
  end
end
```

Pretty awesome, right? We basically just told ActiveRecord to add a column to the animals table, call it gender, and it's going to be a string.

Notice how we incremented the number in the file name there? Imagine for a minute that you deleted your original database and wanted to execute the migrations again. ActiveRecord is going to execute each file, but it has to do so in some order and it happens to do that in alpha-numerical order. If we didn't have the numbers, our add_column migration would have tried to run first ('a' comes before 'c') and our animals table wouldn't have even been created yet! So we used some numbers to make sure they execute in order. In reality our two-digit system is very rudimentary.

Now that you've saved the migration, back to the terminal to run it:

`rake db:migrate`

Awesome! Now go back to the console: `rake console`

and check it out:

```ruby
Animal.column_names
#=> ["id", "name", "age", "breed", "gender"]
```

Great!

Nope- wait. Word just came down from the boss- you weren't supposed to ship that change yet! OH NO! No worries, we'll rollback to the first migration.

Run `rake -T`. Which command should we use?

`rake db:rollback`

Then double check:


```ruby
Animal.column_names
#=> ["id", "name", "age", "breed"]
```

Oh good, your job is saved. Thanks ActiveRecord! Now when the boss says it's actually time to add that column, you can just run it again!

`rake db:migrate`

We just notices we are only adding cats to our table but our table name is animals. Let's write a migration `03_rename_animals_to_cats.rb` in our migrate folder that changes the name of our table.

```ruby
# db/migrate/03_rename_animals_to_cats.rb

class RenameAnimalsToCats < ActiveRecord::Migration
  def up
    rename_table :animals, :cats
  end
  
  def down
     rename_table :cats, :animals
  end
end
```
Before running the migration, we need to change the model declaration file manually (change the `animals.rb` file to `cats.rb`, and the class name to Cat) and also change the `environment.rb` file to `require_relative 'cat.rb'` instead of `require_relative 'animal.rb'`.

```ruby
require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/animal.sqlite"
)

require_relative 'cat.rb'
```

Let us assume we want to change the `name` attribute of our cats to `firstname`.

Again we need to create a new migration for this.
Because this is our fourth migration lets name it `04_rename_column_name_to_firstname.rb`

```ruby
# db/migrate/04_rename_column_name_to_firstname.rb

class RenameColumnNameToFirstname < ActiveRecord::Migration
  def up
    rename_column :cats, :name, :firstname
  end
  
  def down
    rename_column :cats, :firstname, :name
  end
end
```
After running `rake db:migrate` we should make sure that the migration works. Head over to the `rake console` and type `Cat.column_names`. 


```ruby
Cat.column_names
=> ["id", "firstname", "age", "breed", "gender"]
```


Every cat should also have a owner. Let's create a separate "Owners" table. First, create a new migration named `05_create_owners.rb`. The owners table should only have a name attribute.


```ruby
# db/migrate/05_create_owners.rb

class CreateOwners < ActiveRecord::Migration
  def up
    create_table :owners do |t|
      t.string :name
    end
  end

  def down
    drop_table :owners
  end
end
```
Now create the `06_add_column_to_cats.rb` migration, and add the owner_id column to the cats table. This column will serve as the foreign key joining the cats table to the owners table.

```ruby
class AddColumnToCats < ActiveRecord::Migration
  def up
    add_column :cats, :owner_id, :integer
  end
  
  def down
    remove_column :cats, :owner_id
  end
end
```
Now we have two tables and every cat knows who its owner is!
