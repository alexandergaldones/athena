function testcase_athena.argument.is_integer()
{
	bashunit.test.assert_return "athena.argument.is_integer" 0
	bashunit.test.assert_return "athena.argument.is_integer" 1
	bashunit.test.assert_return.expects_fail "athena.argument.is_integer" a
	bashunit.test.assert_return.expects_fail "athena.argument.is_integer"
}

function testcase_athena.argument.pop_arguments()
{
	local -a arguments
	local -a array

	athena.argument.set_arguments one two three
	athena.argument.pop_arguments 1
	athena.argument.get_arguments arguments
	array=(two three)
	bashunit.test.assert_array arguments array
}

function testcase_athena.argument.remove_argument()
{
	local -a arguments
	local -a array

	athena.argument.set_arguments one --arg=two three
	athena.argument.remove_argument "--arg"
	athena.argument.get_arguments arguments
	array=(one three)
	bashunit.test.assert_array arguments array

	athena.argument.set_arguments one --arg=two three
	athena.argument.remove_argument "three"
	athena.argument.get_arguments arguments
	array=(one --arg=two)
	bashunit.test.assert_array arguments array

	athena.argument.set_arguments one --arg=two three
	athena.argument.remove_argument "four"
	athena.argument.get_arguments arguments
	array=(one --arg=two three)
	bashunit.test.assert_array arguments array

	athena.argument.set_arguments one --arg=two three
	athena.argument.remove_argument 2
	athena.argument.get_arguments arguments
	array=(one three)
	bashunit.test.assert_array arguments array

	athena.argument.set_arguments one cmd two /opt/cmd
	athena.argument.remove_argument 2
	athena.argument.get_arguments arguments
	array=(one two /opt/cmd)
	bashunit.test.assert_array arguments array

	athena.argument.set_arguments --one cmd two /opt/cmd
	athena.argument.remove_argument 2
	athena.argument.get_arguments arguments
	array=(--one two /opt/cmd)
	bashunit.test.assert_array arguments array

	athena.argument.set_arguments --one cmd two /opt/cmd "--myarg='value with spaces'"
	athena.argument.remove_argument "--myarg"
	athena.argument.get_arguments arguments
	array=(--one cmd two /opt/cmd)
	bashunit.test.assert_array arguments array

	athena.argument.set_arguments --one cmd two /opt/cmd "--myarg='value with spaces'"
	athena.argument.remove_argument 4
	athena.argument.get_arguments arguments true
	array=(--one cmd two "--myarg='value with spaces'")
	bashunit.test.assert_array arguments array

	athena.argument.set_arguments -p=4449 -e GRID_TIMEOUT=2000
	athena.argument.remove_argument -p
	athena.argument.get_arguments arguments true
	array=(-e GRID_TIMEOUT=2000)
	bashunit.test.assert_array arguments array
}

function testcase_athena.argument.set_arguments()
{
	local -a args=(one --arg=two three)
	local -a arguments

	athena.argument.set_arguments "${args[@]}"
	athena.argument.get_arguments arguments
	bashunit.test.assert_array arguments args
}

function testcase_athena.argument.append_to_arguments()
{
	local args=(one --arg=two three)
	local -a arguments

	athena.argument.set_arguments "${args[@]}"
	athena.argument.append_to_arguments "four"
	args[${#args[*]}]=four
	athena.argument.get_arguments arguments
	bashunit.test.assert_array arguments args
}

function testcase_athena.argument.prepend_to_arguments()
{
	local args=(one --arg=two three)
	local -a arguments

	athena.argument.set_arguments "${args[@]}"
	athena.argument.prepend_to_arguments "four" "five" "six and seven"
	args=( four five "six and seven" "${args[@]}" )
	athena.argument.get_arguments arguments
	bashunit.test.assert_array arguments args
}

function testcase_athena.argument.get_argument()
{
	athena.argument.set_arguments one two ten
	bashunit.test.assert_value "ten" "$(athena.argument.get_argument 3)"

	athena.argument.set_arguments one two ten --arg=eleven
	bashunit.test.assert_value "eleven" "$(athena.argument.get_argument --arg)"

	bashunit.test.assert_exit_code.expects_fail "athena.argument.get_argument" "spinpans"

	athena.argument.set_arguments one two ten --arg=eleven --root-dir=/projects/example-android-project
	bashunit.test.assert_value "/projects/example-android-project" "$(athena.argument.get_argument --root-dir)"

	athena.argument.set_arguments one two ten --arg=eleven --root-dir=~/projects/example-android-project
	bashunit.test.assert_value "~/projects/example-android-project" "$(athena.argument.get_argument --root-dir)"

	athena.argument.set_arguments one two ten --arg=eleven --myoption ~/projects/example-android-project
	bashunit.test.assert_value "" "$(athena.argument.get_argument --myoption)"

	athena.argument.set_arguments '--myval="option with spaces"'
	bashunit.test.assert_output "athena.argument.get_argument" '"option with spaces"' "--myval"

	athena.argument.set_arguments '--myval="option \"with spaces"'
	bashunit.test.assert_output "athena.argument.get_argument" '"option \"with spaces"' "--myval"

	athena.argument.set_arguments '--myval="option \"with spaces"\'
	bashunit.test.assert_output "athena.argument.get_argument" '"option \"with spaces"\' "--myval"
}

function testcase_athena.argument.get_argument_and_remove()
{
	local -a arguments
	local -a array

	athena.argument.set_arguments one two --arg=three
	athena.argument.get_argument_and_remove --arg

	bashunit.test.assert_value "$argument" "three"
	array=(one two)
	athena.argument.get_arguments arguments
	bashunit.test.assert_array arguments array

	athena.argument.set_arguments aaa bbb --param=ccc
	athena.argument.get_argument_and_remove "--param" "value"
	bashunit.test.assert_value "$value" "ccc"
	array=(aaa bbb)
	athena.argument.get_arguments arguments
	bashunit.test.assert_array arguments array

	local argument
	athena.argument.set_arguments -p=4449 -e GRID_TIMEOUT=2000
	athena.argument.get_argument_and_remove "-p" "argument"
	array=(-e GRID_TIMEOUT=2000)
	bashunit.test.assert_value "4449" $argument
	athena.argument.get_arguments arguments
	bashunit.test.assert_array arguments array
}

function testcase_athena.argument.get_path_from_argument()
{
	tmpfile=$(mktemp $HOME/xpto.$(date +%s).XXX)
	athena.argument.set_arguments "--path=$tmpfile"
	bashunit.test.assert_value "$tmpfile" "$(athena.argument.get_path_from_argument --path)"

	athena.argument.set_arguments "--path=/does/not/exist"
	bashunit.test.assert_exit_code.expects_fail "athena.argument.get_path_from_argument" "--path"

	athena.argument.set_arguments "--arg=myarg" "$tmpfile"
	bashunit.test.assert_output "athena.argument.get_path_from_argument" "$tmpfile" "2"
	rm $tmpfile
}

function testcase_athena.argument.get_path_from_argument_and_remove()
{
	tmpfile=$(mktemp $HOME/xpto.$(date +%s).XXX)
	athena.argument.set_arguments "--path=$tmpfile"
	athena.argument.get_path_from_argument_and_remove --path
	bashunit.test.assert_value "$tmpfile" "$path"
	rm $tmpfile

	athena.argument.set_arguments "--path=/does/not/exist"
	bashunit.test.assert_exit_code.expects_fail "athena.argument.get_path_from_argument_and_remove" "--path"
}

function testcase_athena.argument.argument_exists()
{
	athena.argument.set_arguments "--myarg=2"
	bashunit.test.assert_return "athena.argument.argument_exists" "--myarg"

	bashunit.test.assert_return.expects_fail "athena.argument.argument_exists" ""
	bashunit.test.assert_return.expects_fail "athena.argument.argument_exists" "--myarg2"

	athena.argument.set_arguments "--list"
	bashunit.test.assert_return.expects_fail "athena.argument.argument_exists" "--listf"

	athena.argument.set_arguments "/path/to/somewhere-f-wrong"
	bashunit.test.assert_return.expects_fail "athena.argument.argument_exists" "-f"
}

function testcase_athena.argument.argument_exists_and_remove()
{
	athena.argument.set_arguments "--myarg=2"
	athena.argument.argument_exists_and_remove "--myarg"
	bashunit.test.assert_value 0 $?
	athena.argument.get_arguments arguments
	array=()
	bashunit.test.assert_array arguments array

	athena.argument.set_arguments "--myarg=2"
	athena.argument.argument_exists_and_remove "--myarg2"
	bashunit.test.assert_value.expects_fail 0 $?
	athena.argument.get_arguments arguments
	array=(--myarg=2)
	bashunit.test.assert_array arguments array

	athena.argument.set_arguments "myarg=val2"
	athena.argument.argument_exists_and_remove "myarg" "arg"
	bashunit.test.assert_value "val2" "$arg"
	athena.argument.get_arguments arguments
	array=()
	bashunit.test.assert_array arguments array
}

function testcase_athena.argument.argument_exists_or_fail()
{
	athena.argument.set_arguments "--arg1=xpto"
	bashunit.test.assert_return "athena.argument.argument_exists_or_fail" "--arg1"
	bashunit.test.assert_exit_code.expects_fail "athena.argument.argument_exists_or_fail" "arg2"
}

function testcase_athena.argument.nr_args_lt()
{
	athena.argument.set_arguments "--arg1=xpto"
	bashunit.test.assert_return "athena.argument.nr_args_lt" 2
	bashunit.test.assert_return.expects_fail "athena.argument.nr_args_lt" 1
}

function testcase_athena.argument.argument_is_not_empty()
{
	bashunit.test.assert_return "athena.argument.argument_is_not_empty" "val"
	bashunit.test.assert_return.expects_fail "athena.argument.argument_is_not_empty" ""
}

function testcase_athena.argument.argument_is_not_empty_or_fail()
{
	bashunit.test.assert_return "athena.argument.argument_is_not_empty_or_fail" "val"
	bashunit.test.assert_exit_code.expects_fail "athena.argument.argument_is_not_empty_or_fail" ""
}

function testcase_athena.argument.nr_of_arguments()
{
	athena.argument.set_arguments one two three
	bashunit.test.assert_output "athena.argument.nr_of_arguments" "3"

	ATHENA_ARGS=()
	bashunit.test.assert_output "athena.argument.nr_of_arguments" "0"
}

function testcase_athena.argument.string_contains()
{
	bashunit.test.assert_return "athena.argument.string_contains" "one two three" "three"
	bashunit.test.assert_return.expects_fail "athena.argument.string_contains" "one two three" "four"
}

function testcase_athena.argument.get_integer_argument()
{
	athena.argument.set_arguments one two 10
	bashunit.test.assert_output "athena.argument.get_integer_argument" 10 3
	bashunit.test.assert_exit_code "athena.argument.get_integer_argument" 3
	bashunit.test.assert_exit_code.expects_fail "athena.argument.get_integer_argument" 1
}

function testcase_athena.argument.get_arguments()
{

	athena.argument.set_arguments one --arg=two three
	bashunit.test.assert_value "one --arg=two three" "$(athena.argument.get_arguments)"

	athena.argument.set_arguments one --arg=two 'something in between' three
	bashunit.test.assert_value "one --arg=two something in between three" "$(athena.argument.get_arguments)"


	local -a my_array

	athena.argument.set_arguments one two "three horses on the ground" four five "--six=6"

	bashunit.test.assert_exit_code.expects_fail athena.argument.get_arguments 1

	athena.argument.get_arguments my_array
	bashunit.test.assert_value "${my_array[*]}" "one two three horses on the ground four five --six=6"

	local -a myarguments
	local -a expected
	expected=(one --arg=two three)
	athena.argument.set_arguments one --arg=two three
	athena.argument.get_arguments myarguments
	bashunit.test.assert_array expected myarguments

	expected=(one --arg=two three "four and five" --six "is not" 7)
	athena.argument.set_arguments "${expected[@]}"
	athena.argument.get_arguments myarguments
	bashunit.test.assert_array expected myarguments
}
