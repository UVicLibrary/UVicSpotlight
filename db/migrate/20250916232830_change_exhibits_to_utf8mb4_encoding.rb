class ChangeExhibitsToUtf8mb4Encoding < ActiveRecord::Migration[7.0]

  # Change translation table's character set to utf8mb4
  # See https://gist.github.com/tjh/1711329

  def up
    execute "ALTER TABLE `spotlight_exhibits` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
  end
end
