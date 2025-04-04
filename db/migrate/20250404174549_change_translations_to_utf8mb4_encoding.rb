class ChangeTranslationsToUtf8mb4Encoding < ActiveRecord::Migration[7.0]

  # Change translation table's character set to utf8mb4
  # See https://gist.github.com/tjh/1711329

  def up
    execute "ALTER TABLE `translations` CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;"
  end

end
