name "Package: password"
rs_ca_ver 20161221
short_description "Generates Password"
package "password"

########################################################
# USAGE
# This will generate a randomish password inline in rcl
#
#  EXAMPLE
#  -----
# 
# You can call the password generator without any special characters
#  call password.generate_password(10,[]) retrieve $password
#
# Or
# You can tell it which special characters to pick from
# call password.generate_password(10,[!@#$?]) retrieve $password
#  ------
define generate_password($char_count,$symbol_array) return $password do
  $lc_array=split('abcdefghijklmnopqrstuvwxyz','')
  $uc_array=split(upcase('abcdefghijklmnopqrstuvwxyz'),'')
  $pw_array = $lc_array + $uc_array + to_a([0..9])
  $password_array = []
  $index_array = []
  if size($symbol_array) > 0
    foreach $symbol in $symbol_array do
      $pw_array << $symbol
    end
  end
  while size($password_array) <= to_n($char_count) do
    call gen_index(size($pw_array)) retrieve $new_index
    $index_array << $new_index
    $password_array << $pw_array[$new_index]
  end
  $password = join($password_array,'')
end

define gen_index($total_length) return $new_index do
  $n1 = to_n(strftime(now(), '%3N'))
  while $n1 >= to_n($total_length) do
    $n1 = to_n(strftime(now(), '%3N'))
  end
  $new_index = $n1
end