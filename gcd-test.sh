#!/bin/bash

#実行すると最大公約数シェルスクリプトへさまざまな入力を行う
#最大公約数シェルスクリプトが想定した挙動をしていない場合にエラー終了を行う

echo -e "●gcd.shのテストをします。\n●各ケースで合格 -PASS-と出れば、gcd.shの出力は期待値どおりです。\n●不合格-FAIL-と出れば、どの値が期待値と異なるかが表示されます。\n"

#failカウント
fail=0

#----テスト結果を判定する関数----
check_test() {
  local desc=$1 #テスト説明
  local exit_code=$2 #実行後の終了コード
  local stdout=$3 #標準出力の内容
  local stderr=$4 #標準エラー出力の内容
  local expect_error=$5 #エラーが期待されるならtrue、されないならfalse
  local expect_gcd=$6 #正常終了が期待されるなら最大公約数の値

#エラーが期待される場合
if [ "$expect_error" = "true" ]; then
    if [ "$exit_code" -eq 1 ] && [ -n "$stderr" ]; then
      #終了コードが1(エラー)で、標準エラー出力に何かメッセージがあれば合格
      echo "合格-PASS-: $desc"
    else
      #そうでなければ失敗扱い
      echo "不合格-FAIL-: $desc"
      echo "   Expected: 実行後の終了コードは1で、標準出力は空。"
      echo "   Got: 実行後の終了コードは$exit_codeで、標準出力は$stderrでした。"
      fail=1
    fi
#正常終了が期待される場合
else
        #stdoutから数字だけを取り出す（数字が1つ以上連続する部分を全て抽出し|最初の1個だけ出力）
	stdout_number=$(echo "$stdout" | grep -oE '[0-9]+' | head -n1)
    if [ "$exit_code" -eq 0 ] && [ "$stdout_number" = "$expect_gcd" ] && [ -z "$stderr" ]; then
      #終了コードが0で、標準出力が期待値、標準エラーは空ならば合格
      echo "合格-PASS-: $desc"
    else
      # そうでなければ失敗
      echo "不合格-FAIL-: $desc"
      echo "   Expected: 実行後の終了コードは0で、標準出力は$expect_gcd、標準エラー出力は空でした。"
      echo "   Got: 実行後の終了コードは$exit_codeで、標準出力は$stdout_number、標準エラー出力は$stderrでした。"
      fail=1
    fi
  fi
}

#----テストケース配列----
#各要素は「引数1 引数2 期待エラー(true/false) 期待最大公約数」の順
testcases=(
  "12 18 false 6"
  "17 13 false 1"
  "100000000 50000000 false 50000000"
  "0 5 true ''"
  "5 0 true ''"
  "-5 10 true ''"
  "10 -5 true ''"
  "3.14 10 true ''"
  "10 3.14 true ''"
  "abc 5 true ''"
  "5 abc true ''"
  "12 3 5 true ''"
  "012 5 true ''"
  "12345678901234567890 1 true ''"
  "'' 5 true ''"
)


#----テストケースを1つずつ処理----
for tc in "${testcases[@]}"; do
  #evalコマンドで、testcaseを配列として展開
  eval "args=($tc)"

  #テストケースの中身説明文
  desc="${args[*]}"

  #testcaseの配列展開後の長さ取得
  length=${#args[@]}
  
  expect_err=${args[$((length-2))]}
  expect_gcd=${args[$((length-1))]}

  #引数として渡す部分の抽出のため、最後の2要素を除く
  #引数部分を抽出しないと、引数の個数が正しいかの判定ができないから。
  unset 'args[$((length-1))]'  #最後の要素（期待最大公約数）削除
  unset 'args[$((length-2))]'  #その前の要素（期待エラー）削除
  arg_value=("${args[@]}") #引数のみの配列になった

  #スクリプトを実行し標準出力を取得すると同時に、
  # 標準エラーはファイルにリダイレクトしてあとで読み込む
  stdout=$(./gcd.sh "${arg_value[@]}" 2>stderr.tmp)

  # 直前のコマンドの終了コードを取得
  exit_code=$?

  # ファイルから標準エラーを読み込み
  stderr=$(<stderr.tmp)
  
  # 一時ファイルを削除
  rm -f stderr.tmp

  # 判定関数に結果を渡して判定・表示
  check_test "$desc" "$exit_code" "$stdout" "$stderr" "$expect_err" "$expect_gcd"
done


#もし失敗が1つでもあれば、このテストスクリプト自体は失敗終了にする
if [ "$fail" -eq 1 ]; then
  echo "FAIL: Some tests failed."
  exit 1
fi

#全部成功なら正常終了
exit 0


