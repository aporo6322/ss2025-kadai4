#!/bin/bash

#2つの自然数を引数とし、1つの自然数の最大公約数を出力とする
#その他、正しくない入力を行った際はエラー終了する

MAX_DIGITS=9 #この桁より多い引数は計算対象外とする。

#----引数の検証関数----
validate_input() {
  local input=$1

  #正の自然数でないとNG
  #先頭に0なし、1以上の整数であること。
  if ! [[ "$input" =~ ^[1-9][0-9]*$ ]]; then
    return 1
  fi

  #桁数が制限数以上であるとNG
  if [ "${#input}" -gt "$MAX_DIGITS" ]; then
    return 1
  fi

  #空白文字が含まれているとNG
  if [[ "$input" =~ [[:space:]] ]]; then
    return 1
  fi

  return 0
}

#----引数の個数チェック----
if [ "$#" -ne 2 ]; then
  echo "エラー: 引数は自然数2つのみ指定してください。" >&2
  exit 1
fi

input_a=$1
input_b=$2

#----引数の検証関数を使ったチェック----
#もしvalidate_inputの実行結果が「!成功」=「失敗」だったらエラー出力
if ! validate_input "$input_a"; then
  echo " エラー: 引数1つ目 \"$input_a\" は無効です。自然数（1〜$(printf '9%.0s' $(seq 1 $MAX_DIGITS))）を指定してください。" >&2
  exit 1
fi

if ! validate_input "$input_b"; then
  echo "エラー: 引数2つ目 \"$input_b\" は不正です。自然数（1〜$(printf '9%.0s' $(seq 1 $MAX_DIGITS))）を指定してください。" >&2
  exit 1
fi

#----最大公約数を求める（ユークリッドの互除法）----
while [ "$input_b" -ne 0 ]; do
  temp=$input_b
  input_b=$((input_a % input_b))
  input_a=$temp
done

#最大公約数を出力する
echo "２つの引数の最大公約数は$input_aです。"
exit 0



