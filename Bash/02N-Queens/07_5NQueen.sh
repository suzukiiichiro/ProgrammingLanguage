#!/bin/bash

##
 # Bash(シェルスクリプト)で学ぶアルゴリズムとデータ構造  
 # 一般社団法人  共同通信社  情報技術局  鈴木  維一郎(suzuki.iichiro@kyodonews.jp)
 #
 # Java/C/Lua/Bash版
 # https://github.com/suzukiiichiro/N-Queen
 #
 # ステップバイステップでＮ−クイーン問題を最適化
 #  １．ブルートフォース（力まかせ探索） NQueen1()
 #  ２．配置フラグ（制約テスト高速化）   NQueen2()
 #  ３．バックトラック                   NQueen3()
 #  ４．ビットマップ                     NQueen4()
 #<>５．対象解除法                       NQueen5()

##
# 5. 対称解除法 ユニーク解(回転・反転）を使って高速化
##


 #  5．対称解除法
 #     一つの解には、盤面を９０度、１８０度、２７０度回転、及びそれらの鏡像の合計
 #     ８個の対称解が存在する。対照的な解を除去し、ユニーク解から解を求める手法。
 # 
 # ■ユニーク解の判定方法
 #   全探索によって得られたある１つの解が、回転・反転などによる本質的に変わること
 # のない変換によって他の解と同型となるものが存在する場合、それを別の解とはしない
 # とする解の数え方で得られる解を「ユニーク解」といいます。つまり、ユニーク解とは、
 # 全解の中から回転・反転などによる変換によって同型になるもの同士をグループ化する
 # ことを意味しています。
 # 
 #   従って、ユニーク解はその「個数のみ」に着目され、この解はユニーク解であり、こ
 # の解はユニーク解ではないという定まった判定方法はありません。ユニーク解であるか
 # どうかの判断はユニーク解の個数を数える目的の為だけに各個人が自由に定義すること
 # になります。もちろん、どのような定義をしたとしてもユニーク解の個数それ自体は変
 # わりません。
 # 
 #   さて、Ｎクイーン問題は正方形のボードで形成されるので回転・反転による変換パター
 # ンはぜんぶで８通りあります。だからといって「全解数＝ユニーク解数×８」と単純には
 # いきません。ひとつのグループの要素数が必ず８個あるとは限らないのです。Ｎ＝５の
 # 下の例では要素数が２個のものと８個のものがあります。
 #
 #
 # Ｎ＝５の全解は１０、ユニーク解は２なのです。
 # 
 # グループ１: ユニーク解１つ目
 # - - - Q -   - Q - - -
 # Q - - - -   - - - - Q
 # - - Q - -   - - Q - -
 # - - - - Q   Q - - - -
 # - Q - - -   - - - Q -
 # 
 # グループ２: ユニーク解２つ目
 # - - - - Q   Q - - - -   - - Q - -   - - Q - -   - - - Q -   - Q - - -   Q - - - -   - - - - Q
 # - - Q - -   - - Q - -   Q - - - -   - - - - Q   - Q - - -   - - - Q -   - - - Q -   - Q - - -
 # Q - - - -   - - - - Q   - - - Q -   - Q - - -   - - - - Q   Q - - - -   - Q - - -   - - - Q -
 # - - - Q -   - Q - - -   - Q - - -   - - - Q -   - - Q - -   - - Q - -   - - - - Q   Q - - - -
 # - Q - - -   - - - Q -   - - - - Q   Q - - - -   Q - - - -   - - - - Q   - - Q - -   - - Q - -
 #
 # 
 #   それでは、ユニーク解を判定するための定義付けを行いますが、次のように定義する
 # ことにします。各行のクイーンが右から何番目にあるかを調べて、最上段の行から下
 # の行へ順番に列挙します。そしてそれをＮ桁の数値として見た場合に最小値になるもの
 # をユニーク解として数えることにします。尚、このＮ桁の数を以後は「ユニーク判定値」
 # と呼ぶことにします。
 # 
 # - - - - Q   0
 # - - Q - -   2
 # Q - - - -   4   --->  0 2 4 1 3  (ユニーク判定値)
 # - - - Q -   1
 # - Q - - -   3
 # 
 # 
 #   探索によって得られたある１つの解(オリジナル)がユニーク解であるかどうかを判定
 # するには「８通りの変換を試み、その中でオリジナルのユニーク判定値が最小であるか
 # を調べる」ことになります。しかし結論から先にいえば、ユニーク解とは成り得ないこ
 # とが明確なパターンを探索中に切り捨てるある枝刈りを組み込むことにより、３通りの
 # 変換を試みるだけでユニーク解の判定が可能になります。
 #  
 # 
 # ■ユニーク解の個数を求める
 #   先ず最上段の行のクイーンの位置に着目します。その位置が左半分の領域にあればユ
 # ニーク解には成り得ません。何故なら左右反転によって得られるパターンのユニーク判
 # 定値の方が確実に小さくなるからです。また、Ｎが奇数の場合に中央にあった場合はど
 # うでしょう。これもユニーク解には成り得ません。何故なら仮に中央にあった場合、そ
 # れがユニーク解であるためには少なくとも他の外側の３辺におけるクイーンの位置も中
 # 央になければならず、それは互いの効き筋にあたるので有り得ません。
 #
 #
 # ***********************************************************************
 # 最上段の行のクイーンの位置は中央を除く右側の領域に限定されます。(ただし、N ≧ 2)
 # ***********************************************************************
 # 
 #   次にその中でも一番右端(右上の角)にクイーンがある場合を考えてみます。他の３つ
 # の角にクイーンを置くことはできないので(効き筋だから）、ユニーク解であるかどうか
 # を判定するには、右上角から左下角を通る斜軸で反転させたパターンとの比較だけになり
 # ます。突き詰めれば、
 # 
 # [上から２行目のクイーンの位置が右から何番目にあるか]
 # [右から２列目のクイーンの位置が上から何番目にあるか]
 # 
 #
 # を比較するだけで判定することができます。この２つの値が同じになることはないからです。
 # 
 #       3 0
 #       ↓↓
 # - - - - Q ←0
 # - Q - - - ←3
 # - - - - -         上から２行目のクイーンの位置が右から４番目にある。
 # - - - Q -         右から２列目のクイーンの位置が上から４番目にある。
 # - - - - -         しかし、互いの効き筋にあたるのでこれは有り得ない。
 # 
 #   結局、再帰探索中において下図の X への配置を禁止する枝刈りを入れておけば、得
 # られる解は総てユニーク解であることが保証されます。
 # 
 # - - - - X Q
 # - Q - - X -
 # - - - - X -
 # - - - - X -
 # - - - - - -
 # - - - - - -
 # 
 #   次に右端以外にクイーンがある場合を考えてみます。オリジナルがユニーク解である
 # ためには先ず下図の X への配置は禁止されます。よって、その枝刈りを先ず入れておき
 # ます。
 # 
 # X X - - - Q X X
 # X - - - - - - X
 # - - - - - - - -
 # - - - - - - - -
 # - - - - - - - -
 # - - - - - - - -
 # X - - - - - - X
 # X X - - - - X X
 # 
 #   次にクイーンの利き筋を辿っていくと、結局、オリジナルがユニーク解ではない可能
 # 性があるのは、下図の A,B,C の位置のどこかにクイーンがある場合に限られます。従っ
 # て、90度回転、180度回転、270度回転の３通りの変換パターンだけを調べれはよいこと
 # になります。
 # 
 # X X x x x Q X X
 # X - - - x x x X
 # C - - x - x - x
 # - - x - - x - -
 # - x - - - x - -
 # x - - - - x - A
 # X - - - - x - X
 # X X B - - x X X
 #
 #
 # ■ユニーク解から全解への展開
 #   これまでの考察はユニーク解の個数を求めるためのものでした。全解数を求めるには
 # ユニーク解を求めるための枝刈りを取り除いて全探索する必要があります。したがって
 # 探索時間を犠牲にしてしまうことになります。そこで「ユニーク解の個数から全解数を
 # 導いてしまおう」という試みが考えられます。これは、左右反転によるパターンの探索
 # を省略して最後に結果を２倍するというアイデアの拡張版といえるものです。そしてそ
 # れを実現させるには「あるユニーク解が属するグループの要素数はいくつあるのか」と
 # いう考察が必要になってきます。
 # 
 #   最初に、クイーンが右上角にあるユニーク解を考えます。斜軸で反転したパターンが
 # オリジナルと同型になることは有り得ないことと(×２)、右上角のクイーンを他の３つの
 # 角に写像させることができるので(×４)、このユニーク解が属するグループの要素数は必
 # ず８個(＝２×４)になります。
 # 
 #   次に、クイーンが右上角以外にある場合は少し複雑になりますが、考察を簡潔にする
 # ために次の事柄を確認します。
 #
 # TOTAL = (COUNT8 * 8) + (COUNT4 * 4) + (COUNT2 * 2);
 #   (1) 90度回転させてオリジナルと同型になる場合、さらに90度回転(オリジナルか
 #    ら180度回転)させても、さらに90度回転(オリジナルから270度回転)させてもオリ
 #    ジナルと同型になる。  
 #
 #    COUNT2 * 2
 # 
 #   (2) 90度回転させてオリジナルと異なる場合は、270度回転させても必ずオリジナ
 #    ルとは異なる。ただし、180度回転させた場合はオリジナルと同型になることも有
 #    り得る。 
 #
 #    COUNT4 * 4
 # 
 #   (3) (1) に該当するユニーク解が属するグループの要素数は、左右反転させたパターンを
 #       加えて２個しかありません。(2)に該当するユニーク解が属するグループの要素数は、
 #       180度回転させて同型になる場合は４個(左右反転×縦横回転)、そして180度回転させても
 #       オリジナルと異なる場合は８個になります。(左右反転×縦横回転×上下反転)
 # 
 #    COUNT8 * 8 
 #
 #   以上のことから、ひとつひとつのユニーク解が上のどの種類に該当するのかを調べる
 # ことにより全解数を計算で導き出すことができます。探索時間を短縮させてくれる枝刈
 # りを外す必要がなくなったというわけです。 
 # 
 #   UNIQUE  COUNT2      +  COUNT4      +  COUNT8
 #   TOTAL  (COUNT2 * 2) + (COUNT4 * 4) + (COUNT8 * 8)
 #
 # 　これらを実現すると、前回のNQueen3()よりも実行速度が遅くなります。
 # 　なぜなら、対称・反転・斜軸を反転するための処理が加わっているからです。
 # ですが、今回の処理を行うことによって、さらにNQueen5()では、処理スピードが飛
 # 躍的に高速化されます。そのためにも今回のアルゴリズム実装は必要なのです。
 #
#
# N:        Total       Unique     hh:mm:ss
# 2:            0            0            0
# 3:            0            0            0
# 4:            2            1            0
# 5:           10            2            0
# 6:            4            1            0
# 7:           40            6            0
# 8:           92           12            0
# 9:          352           46            1
#10:          724           92            0
#11:         2680          341            3
#12:        14200         1787           18
#13:        73712         9233           99
#14:       365596        45752          573
#15:      2279184       285053         3511
#
##
#---------------------ここから共通部分 ------------------------
# グローバル
U= T= ;				# U:unique T:total
C2= C4= C8= ; # C2:count2 C4:count4 C8:count8
S= SE=; 			# S:size SE:sizee(size-1)
M= SM= LM= ;  # M:mask SM:sidemask LM:lastmask
B= TB= EB=;  	# B:bit TB:topbit EB:endbit
B1= B2=; 			# B1:bound1 B2:bound2
function Check_Qset(){
	((aB[B2]==1))&&{
		for ((p=2,o=1;o<=SE;o++,p<<=1)){
			for ((B=1,y=SE;(aB[y]!=p)&&(aB[o]>=B);y--)){
				 ((B<<=1)) ;
			}
			((aB[o]>B))&& return ;
			((aB[o]<B))&& break ;
		}
		((o>SE))&&{ #90度回転して同型なら180度回転も270度回転も同型である
			((C2++));
			return;
		}
	}
	((aB[SE]==EB))&&{ #180度回転
		for ((y=SE-1,o=1;o<=SE;o++,y--)){
			for ((B=1,p=TB;(p!=aB[y])&&(aB[o]>=B);p>>=1)){
					((B<<=1)) ;
			}
			((aB[o]>B))&& return ;
			((aB[o]<B))&& break ;
		}
		((o>SE))&&{ #90度回転が同型でなくても180度回転が同型であることもある
			((C4++));
			return;
		}
	}
	((aB[B1]==TB))&&{ #270度回転
		for((p=TB>>1,o=1;o<=SE;o++,p>>=1)){
			for((B=1,y=0;(aB[y]!=p)&&(aB[o]>=B);y++)){
					((B<<=1)) ;
			}
			((aB[o]>B))&& return ;
			((aB[o]<B))&& break ;
		}
	}
	((C8++));
}
# 最上段行のクイーンが角以外にある場合の探索 */
function Backtrack2(){
	local v=$1 l=$2 d=$3 r=$4; # v:virtical l:left d:down r:right
	local bm=$((M & ~(l|d|r)));
	((v==SE))&&{ 
		((bm))&&{
			((!(bm&LM)))&&{
					aB[v]=$bm;
					Check_Qset ;
			}
		}
	}||{
		((v<B1))&&{  #上部サイド枝刈り
			((bm|=SM));
			((bm^=SM));
		} 
	 ((v==B2))&&{ #下部サイド枝刈り
			((!(d&SM)))&& return ;
			(((d&SM)!=SM))&&((bm&=SM));
		}
		while ((bm)); do
			((bm^=aB[v]=B=-bm&bm)); 
			Backtrack2 $((v+1)) $(((l|B)<<1)) $(((d|B)))  $(((r|B)>>1)) ;
		done
	}
}
# 最上段行のクイーンが角にある場合の探索
function Backtrack1(){
	local y=$1 l=$2 d=$3 r=$4; #y: l:left d:down r:right bm:bitmap
	local bm=$((M & ~(l|d|r)));
	((y==SE))&&{
		 ((bm))&&{
			 	aB[y]=$bm;
				((C8++)) ;
		 }
	}||{
		 ((y<B1))&&{
			 	((bm|=2));
			 	((bm^=2));
		 }
		 while ((bm)) ;do
			(( bm^=aB[y]=B=(-bm&bm) )) ;
			Backtrack1 $((y+1)) $(((l|B)<<1))  $((d|B)) $(((r|B)>>1)) ;
		 done
	}
}
function BOUND1(){
	(($1<SE))&&{
		(( aB[1]=B=1<<B1 ));
		Backtrack1 2 $(((2|B)<<1)) $((1|B)) $((B>>1));
	}
}
function BOUND2(){
	(($1<$2))&&{
		(( aB[0]=B=1<<B1 ));
		Backtrack2 1 $((B<<1)) $B $((B>>1)) ;
	}
}
#---------------------ここまで共通部分 ------------------------
function N-QueenLogic_Q5(){
	aB[0]=1; 					# aB:BOARD[]
	((SE=(S-1))); 	# SE:sizee
	((M=(1<<S)-1)); # m:mask
	((TB=1<<SE)); 	# TB:topbit
	B1=2;
	while((B1>1&&B1<SE));do
		BOUND1 B1;
		((B1++));
	done
	((SM=LM=(TB|1)));
	((EB=TB>>1));
	B1=1;
	B2=S-2;
	while((B1>0&&B2<SE&&B1<B2));do
		BOUND2 B1 B2;
		((B1++,B2--));
		((EB>>=1));
		((LM|=LM>>1|LM<<1)) ;
	done
	((U=C8+C4+C2)) ;
	((T=C8*8+C4*4+C2*2));
}
N-Queen5(){
	# m:max mi:min st:starttime t:time s:S
  local m=15 mi=2 st= t= s=; 
  echo " N:        Total       Unique        hh:mm" ;
  for ((S=mi;S<=m;S++));do
    C2=0; C4=0; C8=0 st=`date +%s` ;
    N-QueenLogic_Q5 ;
    t=$((`date +%s` - st)) ;
    printf "%2d:%13d%13d%13d\n" $S $T $U $t ;
  done
}

N-Queen5 ; 				# ユニーク解
exit ;

