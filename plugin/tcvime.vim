" vi:set ts=8 sts=2 sw=2 tw=0:
"
" tcvime.vim - tcode,tutcode等の漢字直接入力keymapでの入力補助機能:
"              交ぜ書き変換、部首合成変換、文字ヘルプ表表示機能。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2012-11-18
" Original Plugin: vime.vim by Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

" Description:
" コマンド:
"   :TcvimeOn         キーマッピングを有効化する
"   :TcvimeOff        キーマッピングを無効化する
"   :TcvimeHelp       指定した文字のヘルプ表を表示する
"   :TcvimeHelpBushu  指定した文字を含む行を部首合成変換辞書から検索して表示
"   :TcvimeSetKeymap  keymapをsetする
"   :TcvimeKanjiTable 漢字テーブルファイルを表示して、漢字を選んで入力
"   :TcvimeCloseHelp  ヘルプ用バッファを閉じる
"
" imap:
"   <Leader>q       交ぜ書き変換: 読みを開始
"   <Leader><Space> 交ぜ書き変換: 変換実行
"   <Leader><CR>    交ぜ書き変換: 候補確定
"   <Leader>o       交ぜ書き変換: 活用する語の変換実行
"   <Leader>b       部首合成変換: 直前の2文字の部首合成変換実行
"
" nmap:
"   [count]<Leader><Space>  交ぜ書き変換: カーソル位置以前の[count]文字の変換
"   <Leader><CR>            交ぜ書き変換: 候補確定
"   [count]<Leader>o        交ぜ書き変換: [count]文字の活用する語の変換
"   <Leader>b               部首合成変換: カーソル位置以前の2文字の部首合成変換
"   <Leader>?               打鍵ヘルプ表示: カーソル位置の文字のヘルプ表を表示
"   <Leader>t               漢字テーブルファイル表示
"
" vmap:
"   <Leader>?               打鍵ヘルプ表示: 選択中の(複数)文字のヘルプ表を表示
"
" キー設定オプション:
"  imap:
"    '<Plug>TcvimeIFix'
"       交ぜ書き変換: 候補確定キー。省略値: <Leader><CR>
"       <Leader><CR>を指定する場合の例:
"         imap <Leader><CR> <Plug>TcvimeIFix
"    '<Plug>TcvimeIStart'
"       交ぜ書き変換: 読みを開始するキー。省略値: <Leader>q
"    '<Plug>TcvimeIConvert'
"       交ぜ書き変換: 変換実行キー。省略値: <Leader><Space>
"    '<Plug>TcvimeIKatuyo'
"       交ぜ書き変換: 活用する語の変換実行キー。省略値: <Leader>o
"    '<Plug>TcvimeIBushu'
"       部首合成変換: 直前の2文字の部首合成変換実行キー。省略値: <Leader>b
"
"  nmap:
"    '<Plug>TcvimeNFix'
"       交ぜ書き変換: 候補確定キー。省略値: <Leader><CR>
"       <Leader><CR>を指定する場合の例:
"         nmap <Leader><CR> <Plug>TcvimeNFix
"    '<Plug>TcvimeNConvert'
"       交ぜ書き変換: カーソル位置以前の[count]文字の変換を行うキー。
"       省略値: <Leader><Space>
"    '<Plug>TcvimeNKatuyo'
"       交ぜ書き変換: [count]文字の活用する語の変換を行うキー。
"       省略値: <Leader>o
"    '<Plug>TcvimeNBushu'
"       部首合成変換: カーソル位置以前の2文字の部首合成変換を行うキー。
"       省略値: <Leader>b
"    '<Plug>TcvimeNHelp'
"       打鍵ヘルプ表示: カーソル位置の文字のヘルプ表を表示するキー。
"       省略値: <Leader>?
"    '<Plug>TcvimeNKanjiTable'
"       漢字テーブルファイル表示を行うキー。省略値: <Leader>t
"
"  vmap:
"    '<Plug>TcvimeVHelp'
"       打鍵ヘルプ表示: 選択中の(複数)文字のヘルプ表を表示するキー。
"       省略値: <Leader>?
"       <Leader>? を指定する場合の例:
"         vmap <Leader>? <Plug>TcvimeVHelp
"
" オプション:
"    'tcvime_keyboard'
"       文字ヘルプ表用のキーボード配列を表す文字列。
"       キーの後にスペース、を2回ずつ記述する。
"       例:
"         let tcvime_keyboard = "1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 0 0 \<CR>q q w w e e r r t t y y u u i i o o p p \<CR>a a s s d d f f g g h h j j k k l l ; ; \<CR>z z x x c c v v b b n n m m , , . . / / "
"
"    'tcvime_keymap_for_help'
"       文字ヘルプ表示に使うkeymap。現在のバッファで&keymapが未設定の場合に使用
"
"    'mapleader'
"       キーマッピングのプレフィックス。|mapleader|を参照。省略値: CTRL-K
"       CTRL-Kを指定する場合の例:
"         let mapleader = "\<C-K>"
"
"    'plugin_tcvime_disable'
"       このプラグインを読み込みたくない場合に次のように設定する。
"         let plugin_tcvime_disable = 1

if exists('plugin_tcvime_disable')
  finish
endif

if !exists("tcvime_keymap_for_help")
  let tcvime_keymap_for_help = &keymap
endif

if !exists("tcvime_keyboard")
  let tcvime_keyboard = "1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 0 0 \<CR>q q w w e e r r t t y y u u i i o o p p \<CR>a a s s d d f f g g h h j j k k l l ; ; \<CR>z z x x c c v v b b n n m m , , . . / / "
  " 数字キーの段を表示しない場合は次の文字列を使うようにする(qwerty)
"  let tcvime_keyboard = "q q w w e e r r t t y y u u i i o o p p \<CR>a a s s d d f f g g h h j j k k l l ; ; \<CR>z z x x c c v v b b n n m m , , . . / / "
endif

" 設定
let s:candidate_file = globpath($VIM.','.&runtimepath, 'mazegaki.dic')
let s:bushu_file = globpath($VIM.','.&runtimepath, 'bushu.rev')
let s:kanjitable_file = globpath($VIM.','.&runtimepath, 'kanjitable.txt')
let s:helpbufname = fnamemodify(tempname(), ':p:h') . '/__TcvimeHelp__'
let s:helpbufname = substitute(s:helpbufname, '\\', '/', 'g')
" 辞書ファイルが:ls等で表示されるようにするかどうか。0:表示されない,1:表示する
let s:buflisted = 0

" Mapping
if !exists(":TcvimeOn")
  command TcvimeOn :call <SID>MappingOn()
endif
if !exists(":TcvimeOff")
  command TcvimeOff :call <SID>MappingOff()
endif
" keymapを設定する
" 引数: keymap名
if !exists(":TcvimeSetKeymap")
  command -nargs=1 TcvimeSetKeymap :call <SID>SetKeymap(<args>)
endif
" 指定された文字のヘルプ表を表示する
" 引数: 対象の文字
if !exists(":TcvimeHelp")
  command! -nargs=1 TcvimeHelp call <SID>ShowHelpForStr(<q-args>, 0)
endif
" 指定された文字を含む行を部首合成変換辞書から検索して表示する
" 引数: 対象の文字
if !exists(":TcvimeHelpBushu")
  command! -nargs=1 TcvimeHelpBushu call <SID>ShowHelpForStr(<q-args>, 1)
endif
" 漢字テーブルを表示する
if !exists(":TcvimeKanjiTable")
  command! TcvimeKanjiTable call <SID>KanjiTable_FileOpen()
endif
" ヘルプ用バッファを閉じる
if !exists(":TcvimeCloseHelp")
  command! TcvimeCloseHelp call <SID>CloseHelpBuffer()
endif

" keymapを設定する
function! s:SetKeymap(keymapname)
  if &keymap !=# a:keymapname
    let &keymap = a:keymapname
  endif
endfunction

"   マッピングを有効化
function! s:MappingOn()
  let set_mapleader = 0
  if !exists('g:mapleader')
    let g:mapleader = "\<C-K>"
    let set_mapleader = 1
  endif
  let s:mapleader = g:mapleader

  if !hasmapto('<Plug>TcvimeIFix')
    imap <unique> <silent> <Leader><CR> <Plug>TcvimeIFix
  endif
  if !hasmapto('<Plug>TcvimeIStart')
    imap <unique> <silent> <Leader>q <Plug>TcvimeIStart
  endif
  if !hasmapto('<Plug>TcvimeIConvert')
    imap <unique> <silent> <Leader><Space> <Plug>TcvimeIConvert
  endif
  if !hasmapto('<Plug>TcvimeIKatuyo')
    imap <unique> <silent> <Leader>o <Plug>TcvimeIKatuyo
  endif
  if !hasmapto('<Plug>TcvimeIBushu')
    imap <unique> <silent> <Leader>b <Plug>TcvimeIBushu
  endif
  if !hasmapto('<Plug>TcvimeNFix')
    nmap <unique> <silent> <Leader><CR> <Plug>TcvimeNFix
  endif
  if !hasmapto('<Plug>TcvimeNConvert')
    nmap <unique> <silent> <Leader><Space> <Plug>TcvimeNConvert
  endif
  if !hasmapto('<Plug>TcvimeNKatuyo')
    nmap <unique> <silent> <Leader>o <Plug>TcvimeNKatuyo
  endif
  if !hasmapto('<Plug>TcvimeNBushu')
    nmap <unique> <silent> <Leader>b <Plug>TcvimeNBushu
  endif
  if !hasmapto('<Plug>TcvimeNHelp')
    nmap <unique> <silent> <Leader>? <Plug>TcvimeNHelp
  endif
  if !hasmapto('<Plug>TcvimeNKanjiTable')
    nmap <unique> <silent> <Leader>t <Plug>TcvimeNKanjiTable
  endif
  if !hasmapto('<Plug>TcvimeVHelp')
    vmap <unique> <silent> <Leader>? <Plug>TcvimeVHelp
  endif

  inoremap <script> <silent> <Plug>TcvimeIFix <C-R>=<SID>InputFix(col('.'))<CR>
  inoremap <script> <silent> <Plug>TcvimeIStart <C-R>=<SID>InputStart()<CR>
  inoremap <script> <silent> <Plug>TcvimeIConvert <C-R>=<SID>InputConvert(0)<CR>
  inoremap <script> <silent> <Plug>TcvimeIKatuyo <C-R>=<SID>InputConvert(1)<CR>
  inoremap <script> <silent> <Plug>TcvimeIBushu <C-R>=<SID>InputConvertBushu(col('.'))<CR>
  nnoremap <script> <silent> <Plug>TcvimeNFix :<C-U>call <SID>FixCandidate()<CR>
  nnoremap <script> <silent> <Plug>TcvimeNConvert :<C-U>call <SID>ConvertCount(v:count, 0)<CR>
  nnoremap <script> <silent> <Plug>TcvimeNKatuyo :<C-U>call <SID>ConvertCount(v:count, 1)<CR>
  nnoremap <script> <silent> <Plug>TcvimeNBushu :<C-U>call <SID>ConvertBushu()<CR>
  nnoremap <script> <silent> <Plug>TcvimeNHelp :<C-U>call <SID>ShowStrokeHelp()<CR>
  nnoremap <script> <silent> <Plug>TcvimeNKanjiTable :<C-U>call <SID>KanjiTable_FileOpen()<CR>
  vnoremap <script> <silent> <Plug>TcvimeVHelp :<C-U>call <SID>ShowHelpVisual()<CR>

  if set_mapleader
    unlet g:mapleader
  endif

  augroup Tcvime
  autocmd!
  execute "autocmd BufReadCmd ".s:helpbufname." call <SID>Help_BufReadCmd()"
  augroup END

  "if !exists('s:save_cmdheight')
  "  let s:save_cmdheight = &cmdheight
  "endif
endfunction

"   マッピングを無効化
function! s:MappingOff()
  let set_mapleader = 0
  if !exists('g:mapleader')
    let g:mapleader = "\<C-K>"
    let set_mapleader = 1
  else
    let save_mapleader = g:mapleader
  endif
  let g:mapleader = s:mapleader
  silent! iunmap <Leader><CR>
  silent! iunmap <Leader>q
  silent! iunmap <Leader><Space>
  silent! iunmap <Leader>o
  silent! iunmap <Leader>b
  silent! nunmap <Leader><CR>
  silent! nunmap <Leader><Space>
  silent! nunmap <Leader>o
  silent! nunmap <Leader>b
  silent! nunmap <Leader>?
  silent! nunmap <Leader>t
  if set_mapleader
    unlet g:mapleader
  else
    let g:mapleader = save_mapleader
  endif

  augroup Tcvime
  autocmd!
  augroup END
  "unlet s:save_cmdheight
endfunction

TcvimeOn

"==============================================================================
"				    入力制御

" 読みの入力を開始
function! s:InputStart()
  call s:SetCmdheight()
  call s:StatusSet()
  return ''
endfunction

" Insert modeで交ぜ書き変換を行う。
" 活用する語の変換の場合は、
" 変換対象文字列の末尾に「―」を追加して交ぜ書き辞書を検索する。
" @param katuyo 活用する語の変換かどうか。0:活用しない, 1:活用する
function! s:InputConvert(katuyo)
  let inschars = ''
  let s:is_katuyo = 0
  let status = s:StatusGet(col('.'))
  let len = strlen(status)
  if len > 0
    let s:is_katuyo = a:katuyo
    if s:is_katuyo
      let status = status . '―'
    endif
    let found = s:CandidateSearch(status)
  else
    let s:last_keyword = ''
    call s:InputStart()
  endif
  if exists('found')
    if found == 2
      echo 'CANDIDATE: ' . s:last_candidate
    elseif found == 1
      let inschars = s:InputFix(col('.'))
    elseif found == 0
      echo '交ぜ書き辞書中には見つかりません: <' . status . '>'
    elseif found == -1
      echo '交ぜ書き変換辞書ファイルのオープンに失敗しました: ' . s:candidate_file
    endif
  endif
  return inschars
endfunction

" 確定しようとしている候補が問題ないかどうかチェック
function! s:IsCandidateOK(str)
  if strlen(a:str) > 0 && strlen(s:last_candidate) > 0
    if s:is_katuyo && s:last_keyword ==# (a:str . '―') || s:last_keyword ==# a:str
      return 1
    endif
  endif
  return 0
endfunction

" 候補を確定して、確定した文字列を返す
function! s:InputFix(col)
  let inschars = ''
  let str = s:StatusGet(a:col)
  if s:IsCandidateOK(str)
    let inschars = s:CandidateSelect()
    if strlen(inschars) > 0
      call s:ShowAutoHelp(str, inschars)
      let bs = substitute(str, '.', "\<BS>", "g")
      let inschars = bs . inschars
    endif
  endif
  call s:StatusReset()
  if exists('s:save_cmdheight')
    let &cmdheight = s:save_cmdheight
  endif
  return inschars
endfunction

" &cmdheightが2より小さかったら2に設定する。CANDIDATE:表示のため。
function! s:SetCmdheight()
  let s:save_cmdheight = &cmdheight
  if &cmdheight < 2
    let &cmdheight = 2
  endif
endfunction

" 直前の2文字の部首合成変換を行う
function! s:InputConvertBushu(col)
  let inschars = ''
  if a:col > 2
    let chars = matchstr(getline('.'), '..\%' . a:col . 'c')
    let char1 = matchstr(chars, '^.')
    let char2 = matchstr(chars, '.$')
    let retchar = s:BushuSearch(char1, char2)
    let len = strlen(retchar)
    if len > 0
      let inschars = "\<BS>\<BS>" . retchar
      call s:ShowAutoHelp(chars, retchar)
    else
      echo '部首合成変換ができませんでした: <' . char1 . '>, <' . char2 . '>'
    endif
  endif
  return inschars
endfunction

" 以前のConvertCount()に渡されたcount引数の値。
" countが0で実行された場合に以前のcount値を使うようにするため。
let s:last_count = 0

" 今の位置以前のcount文字を変換する
" @param count 変換する文字列の長さ
" @param katuyo 活用する語の変換かどうか。0:活用しない, 1:活用する
function! s:ConvertCount(count, katuyo)
  let cnt = a:count
  if cnt == 0
    let cnt = s:last_count
    if cnt == 0
      let cnt = 1
    endif
  endif
  let s:last_count = cnt

  " cnt長の文字列にマッチする正規表現を作る
  let i = 0
  let mstr = ''
  while i < cnt
    let mstr = mstr . '.'
    let i = i + 1
  endwhile

  let s:is_katuyo = 0
  let s:status_line = line(".")
  execute "normal! a\<ESC>"
  let chars = matchstr(getline('.'), mstr . '\%' . col("'^") . 'c')

  let len = strlen(chars)
  if len > 0
    let s:status_column = col("'^") - len
    "call s:SetCmdheight()
    let s:is_katuyo = a:katuyo
    if s:is_katuyo
      let chars = chars . '―'
    endif
    let found = s:CandidateSearch(chars)
    if found == 2
      echo 'CANDIDATE: ' . s:last_candidate
    elseif found == 1
      call s:FixCandidate()
    elseif found == 0
      echo '交ぜ書き辞書中には見つかりません: <' . chars . '>'
    elseif found == -1
      echo '交ぜ書き変換辞書ファイルのオープンに失敗しました: ' . s:candidate_file
    endif
  else
    let s:last_keyword = ''
    let s:last_count = 0
    call s:StatusReset()
  endif
endfunction

" ConvertCount()で変換を開始した候補を確定する
function! s:FixCandidate()
  execute "normal! a\<ESC>"
  let inschars = s:InputFix(col("'^"))
  let s:last_count = 0
  call s:InsertString(inschars)
endfunction

" 今の位置以前の2文字を部首合成変換する
function! s:ConvertBushu()
  execute "normal! a\<ESC>"
  let inschars = s:InputConvertBushu(col("'^"))
  call s:InsertString(inschars)
endfunction

" 指定された文字列をバッファにappendする
function! s:InsertString(inschars)
  if strlen(a:inschars) > 0
    let save_bs = &backspace
    set backspace=2
    execute "normal! a" . a:inschars . "\<ESC>"
    let &backspace = save_bs
  endif
endfunction

"==============================================================================
"			     未確定文字管理用関数群

"   未確定文字列が存在するかチェックする
function! s:StatusIsEnable(col)
  if s:status_line != line('.') || s:status_column <= 0 || s:status_column > a:col
    return 0
  endif
  return 1
endfunction

"   未確定文字列を開始する
function! s:StatusSet()
  let s:status_line = line('.')
  let s:status_column = col('.')
  call s:StatusEcho()
endfunction

"   未確定文字列をリセットする
function! s:StatusReset()
  let s:status_line = 0
  let s:status_column = 0
endfunction

"   未確定文字列を「状態」として取得する
function! s:StatusGet(col)
  if !s:StatusIsEnable(a:col)
    return ''
  endif

  " 必要なパラメータを収集
  let stpos = s:status_column - 1
  let len = a:col - s:status_column
  let str = getline('.')

  return strpart(str, stpos, len)
endfunction

"   未確定文字列の開始位置と終了位置を表示(デバッグ用)
function! s:StatusEcho(...)
  echo '読み入力開始;<Leader><Space>:変換,<Leader>o:活用する語の変換,<Leader><CR>:確定'
  "echo "New conversion (line=".s:status_line." column=".s:status_column.")"
endfunction

" 状態リセット
call s:StatusReset()

"==============================================================================
" ヘルプ表示

" 空のヘルプ用バッファを作る
function! s:Help_BufReadCmd()
endfunction

" ヘルプ用バッファを開く
function! s:OpenHelpBuffer()
  if s:SelectWindowByName(s:helpbufname) < 0
    execute "silent normal! :sp " . s:helpbufname . "\<CR>"
    set buftype=nofile
    set bufhidden=delete
    set noswapfile
    set winfixheight
    if !s:buflisted
      set nobuflisted
    endif
  endif
  %d _
  5wincmd _
endfunction

" ヘルプ用バッファを閉じる
function! s:CloseHelpBuffer()
  if s:SelectWindowByName(s:helpbufname) > 0
    bwipeout!
  endif
endfunction

" カーソル位置の文字のヘルプ表を表示する
function! s:ShowStrokeHelp()
  let ch = matchstr(getline('.'), '\%' . col('.') . 'c.')
  call s:ShowHelp([ch], 0)
endfunction

" Visual modeで選択されている文字列のヘルプ表を表示する
function! s:ShowHelpVisual()
  let save_reg = @@
  silent execute 'normal! `<' . visualmode() . '`>y'
  call s:ShowHelpForStr(substitute(@@, '\n', '', 'g'), 0)
  let @@ = save_reg
endfunction

" 変換で確定した文字列のヘルプ表を表示する
function! s:ShowAutoHelp(yomi, str)
  let yomichars = split(a:yomi, '\zs')
  let chars = split(a:str, '\zs')
  " 読みで入力した漢字はヘルプ表示不要なので取り除く
  call filter(chars, 'index(yomichars, v:val) == -1')
  call s:ShowHelp(chars, 0)
endfunction

" 指定された文字列の各文字のヘルプ表を表示する
function! s:ShowHelpForStr(str, forcebushu)
  let ar = split(a:str, '\zs')
  call s:ShowHelp(ar, a:forcebushu)
endfunction

" 指定された文字配列のヘルプ表を表示する
function! s:ShowHelp(ar, forcebushu)
  let keymap = &keymap
  if strlen(keymap) == 0
    let keymap = g:tcvime_keymap_for_help
    if strlen(keymap) == 0
      echo 'tcvime文字ヘルプ表示には、keymapオプションかg:tcvime_keymap_for_helpの設定要'
      return
    endif
  endif
  let curbuf = bufnr('')
  call s:OpenHelpBuffer()
  let winwidth = winwidth(0)
  let lastcol = 0
  let lastfrom = 1
  let width = 0
  let numch = 0
  let skipchars = []
  for ch in a:ar
    if strlen(ch) == 0 || ch == "\<CR>"
      " echo '文字ヘルプ表表示に指定された文字が空です。無視します'
      continue
    endif
    call cursor(line('$'), 1)
    if a:forcebushu == 1
      let ret = s:ShowHelpBushuDic(ch)
    else
      let ret = s:ShowHelpChar(ch, keymap)
    endif
    if ret == -1 " ストローク表も部首合成辞書も表示できなかった場合
      call add(skipchars, ch)
      continue
    endif
    let numch += 1
    if ret == 0 " ShowHelpBushuDic
      continue
    endif
    " 表を横に並べる
    if lastcol == 0 " 最初の表の場合は変数初期化だけ
      let lastcol = col('$')
      let lastfrom = line('.')
      let width = lastcol + 2
      continue
    endif
    if lastcol + width >= winwidth " さらに並べるとはみ出す場合はそのままに
      let lastcol = col('$')
      let lastfrom = line('.')
      continue
    endif
    let ln = line('.')
    let save_reg = @@
    execute "normal! \<C-V>GkI  \<ESC>\<C-V>Gk$x" . lastfrom . "G$p"
    let @@ = save_reg
    let lastcol = col('$')
    silent! execute ln . ',$-1d _'
  endfor
  if numch == 0
    call s:CloseHelpBuffer()
  else
    silent! $g/^$/d _ " 末尾の余分な空行を削除
    normal 1G
    " wincmd p
    execute bufwinnr(curbuf) . 'wincmd w'
  endif
  if len(skipchars) > 0
    redraw
    echo '文字ヘルプで表示できる情報がありません: <' . join(skipchars, ',') . '>'
  endif
endfunction

" 指定された文字のヘルプ表を表示する
function! s:ShowHelpChar(ch, keymap)
  let keyseq = s:SearchKeymap(a:ch, a:keymap)
  if strlen(keyseq) > 0
    call s:SelectWindowByName(s:helpbufname)
    return s:ShowHelpSequence(a:ch, keyseq)
  else
    return s:ShowHelpBushuDic(a:ch)
  endif
endfunction

" 指定された文字とそのストロークを表にして表示する
function! s:ShowHelpSequence(ch, keyseq)
  let from = line('$')
  execute 'normal! O' . g:tcvime_keyboard . "\<CR>\<ESC>"
  let to = line('$')
  let range = from . ',' . to
  let keyseq = a:keyseq
  let i = 0
  while strlen(keyseq) > 0
    let i = i + 1
    let key = strpart(keyseq, 0, 1)
    let keyseq = strpart(keyseq, 1)
    silent! execute range . 's@\V' . key . ' @' . i . '@'
  endwhile
  silent! execute range . 's@^\(....................\). . @\1@e'
  silent! execute range . 's@^\(................\). . @\1@e'
  silent! execute range . 's@\(.\)\(.\)@\1\2@ge'
  silent! execute range . 's@\(.\). @\1@ge'
  silent! execute range . 's@. . @・@g'
  silent! execute range . 's@@ @ge'
  call cursor(to - 1, 1)
  execute 'normal! A    ' . a:ch . "\<ESC>"
  call cursor(from, 1)
  return 1
endfunction

" 部首合成辞書から、指定された文字を含む行を検索して表示する
function! s:ShowHelpBushuDic(ch)
  let lines = s:SearchBushuDic(a:ch)
  call s:SelectWindowByName(s:helpbufname)
  if strlen(lines) > 0
    " バッファ頭でなければ区切りの空行挿入。直前が複数行の部首辞書内容の時必要
    if line('.') > 1
      execute "normal! o\<ESC>"
    endif
    execute 'normal! O' . lines . "\<ESC>"
    return 0
  else
    return -1
  endif
endfunction

" 部首合成辞書から、指定された文字を含む行を検索する
function! s:SearchBushuDic(ch)
  if !s:Bushu_FileOpen()
    return ""
  endif
  let lines = ""
  silent! normal! G$
  if search(a:ch, 'w') != 0
    let lines = getline('.')
    while search(a:ch, 'W') != 0
      let lines = lines . "\<CR>" . getline('.')
    endwhile
  endif
  quit!
  return lines
endfunction

" 指定された文字を入力するためのストロークをkeymapファイルから検索する
function! s:SearchKeymap(ch, keymap)
  let kmfile = globpath(&rtp, "keymap/" . a:keymap . "_" . &encoding . ".vim")
  if filereadable(kmfile) != 1
    let kmfile = globpath(&rtp, "keymap/" . a:keymap . ".vim")
    if filereadable(kmfile) != 1
      return ""
    endif
  endif
  execute "silent normal! :sv " . kmfile . "\<CR>"
  if !s:buflisted
    set nobuflisted
  endif
  let dummy = search('loadkeymap', 'w')
  if search('^[^"].*[^ 	]\+[ 	]\+' . a:ch, 'w') != 0
    let keyseq = substitute(getline('.'), '[ 	]\+.*$', '', '')
  else
    let keyseq = ""
  endif
  quit!
  return keyseq
endfunction

"==============================================================================
"				    辞書検索

" SelectWindowByName(name)
"   Acitvate selected window by a:name.
function! s:SelectWindowByName(name)
  let num = bufwinnr('^' . a:name . '$')
  if num > 0 && num != winnr()
    execute num . 'wincmd w'
  endif
  return num
endfunction

" 交ぜ書き変換辞書データファイルをオープン
function! s:Candidate_FileOpen()
  if filereadable(s:candidate_file) != 1
    return 0
  endif
  if s:SelectWindowByName(s:candidate_file) < 0
    execute 'silent normal! :sv '.s:candidate_file."\<CR>"
    if !s:buflisted
      set nobuflisted
    endif
  endif
  return 1
endfunction

" 検索に使用する状態変数
let s:last_keyword = ''
let s:last_found = 0
let s:last_candidate = ''
let s:last_candidate_str = ''
let s:last_candidate_num = 0
let s:is_katuyo = 0

" 辞書から未確定文字列を検索
" @return -1:辞書が開けない場合, 0:文字列が見つからない場合,
"   1:候補が1つだけ見つかった場合, 2:候補が2つ以上見つかった場合
function! s:CandidateSearch(keyword)
  let found_num = s:last_found
  let uniq = 0
  let ret = 0

  " 検索文字列が前回と同じ時は省略
  if s:last_keyword !=# a:keyword
    let s:last_keyword = a:keyword
    if !s:Candidate_FileOpen()
      return -1
    endif

    " 実際の検索
    if search('^' . a:keyword . ' ', 'w') == 0
      let found_num = 0
    else
      let s:last_candidate = ''
      let s:last_candidate_str = substitute(getline('.'), '^' . a:keyword . ' ', '', '')
      let s:last_candidate_num = 1
      let found_num = line('.')
      if s:last_candidate_str =~# '^/[^/]\+/$'
	let uniq = 1
      endif
    endif
    quit!
  else
    " 次の変換候補を探し出すため
    if s:last_candidate_num > 0 && s:last_candidate != ''
      let s:last_candidate_num = s:last_candidate_num + strlen(s:last_candidate) + 1
    endif
    " 前回変換した文字列を再度変換する場合、候補数をチェックし直す
    if s:last_candidate_num == 1 && s:last_candidate == ''
      if s:last_candidate_str =~# '^/[^/]\+/$'
	let uniq = 1
      endif
    endif
  endif

  if found_num > 0
    " 候補がみつかっているならば、順番に表示する
    let str = ''
    while strlen(str) < 1
      let str = matchstr(s:last_candidate_str, '[^/]\+', s:last_candidate_num)
      if strlen(str) < 1
	let s:last_candidate_num = 1
      endif
    endwhile
    let s:last_candidate = str
    if uniq
      let ret = 1
    else
      let ret = 2
    endif
  else
    " 候補がみつからなかった時、リセット
    let s:last_candidate = ''
    let s:last_candidate_str = ''
    let s:last_candidate_num = 0
    let ret = 0
  endif
  let s:last_found = found_num
  return ret
endfunction

" 確定文字列を取得
function! s:CandidateSelect()
  let inschars = ''
  if strlen(s:last_candidate) > 0
    let i = 0
    let inschars = inschars . s:last_candidate
    let s:status_column = s:status_column + strlen(s:last_candidate)
    let s:last_candidate = ''
    let s:last_candidate_num = 1
  endif
  return inschars
endfunction

" 部首合成辞書データファイルをオープン
function! s:Bushu_FileOpen()
  if filereadable(s:bushu_file) != 1
    return 0
  endif
  if s:SelectWindowByName(s:bushu_file) < 0
    execute 'silent normal! :sv '.s:bushu_file."\<CR>"
    if !s:buflisted
      set nobuflisted
    endif
  endif
  return 1
endfunction

" 等価文字を検索して返す。等価文字がない場合はもとの文字そのものを返す
function! s:BushuAlternative(ch)
  if !s:Bushu_FileOpen()
    return a:ch
  endif
  if search('^.' . a:ch . '$', 'w') != 0
    let retchar = matchstr(getline('.'), '^.')
  else
    let retchar = a:ch
  endif
  quit!
  return retchar
endfunction

" char1とchar2をこの順番で合成してできる文字を検索して返す。
" 見つからない場合は''を返す
function! s:BushuSearchCompose(char1, char2)
  if !s:Bushu_FileOpen()
    return ''
  endif
  if search('^.' . a:char1 . a:char2, 'w') != 0
    let retchar = matchstr(getline('.'), '^.')
  else
    let retchar = ''
  endif
  quit!
  return retchar
endfunction

" 指定された文字を2つの部首に分解する。
" 分解した部首をs:decomp1, s:decomp2にセットする。
" @return 1: 分解に成功した場合、0: 分解できなかった場合
function! s:BushuDecompose(ch)
  if !s:Bushu_FileOpen()
    return 0
  endif
  if search('^' . a:ch . '..', 'w') != 0
    let chars = matchstr(getline('.'), '^...')
    let s:decomp1 = substitute(chars, '^.\(.\).', '\1', '')
    let s:decomp2 = matchstr(chars, '.$')
    let ret = 1
  else
    let ret = 0
  endif
  quit!
  return ret
endfunction

" 合成後の文字が空でなく、元の文字でもないことを確認
" @param ch 合成後の文字
" @param char1 元の文字
" @param char2 元の文字
" @return 1: chが空でもchar1でもchar2でもない場合。0: それ以外の場合
function! s:BushuCharOK(ch, char1, char2)
  if strlen(a:ch) > 0 && a:ch !=# a:char1 && a:ch !=# a:char2
    return 1
  else
    return 0
  endif
endfunction

" 部首合成変換辞書を検索
function! s:BushuSearch(char1, char2)
  let char1 = a:char1
  let char2 = a:char2
  let i = 0
  while i < 2
    " そのまま合成できる?
    let retchar = s:BushuSearchCompose(char1, char2)
    if s:BushuCharOK(retchar, char1, char2)
      return retchar
    endif

    " 等価文字どうしで合成できる?
    if !exists("ch1alt")
      let ch1alt = s:BushuAlternative(char1)
    endif
    if !exists("ch2alt")
      let ch2alt = s:BushuAlternative(char2)
    endif
    let retchar = s:BushuSearchCompose(ch1alt, ch2alt)
    if s:BushuCharOK(retchar, char1, char2)
      return retchar
    endif

    " 等価文字を部首に分解
    if !exists("ch1a1")
      if s:BushuDecompose(ch1alt) == 1
	let ch1a1 = s:decomp1
	let ch1a2 = s:decomp2
	unlet s:decomp1
	unlet s:decomp2
      else
	let ch1a1 = ''
	let ch1a2 = ''
      endif
    endif
    if !exists("ch2a1")
      if s:BushuDecompose(ch2alt) == 1
	let ch2a1 = s:decomp1
	let ch2a2 = s:decomp2
	unlet s:decomp1
	unlet s:decomp2
      else
	let ch2a1 = ''
	let ch2a2 = ''
      endif
    endif

    let lench1a1 = strlen(ch1a1)
    let lench1a2 = strlen(ch1a2)
    let lench2a1 = strlen(ch2a1)
    let lench2a2 = strlen(ch2a2)
    let lench1alt = strlen(ch1alt)
    let lench2alt = strlen(ch2alt)

    " 引き算
    if lench1a1 > 0 && lench1a2 > 0 && ch1a2 ==# ch2alt
      let retchar = ch1a1
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a1 > 0 && lench1a2 > 0 && ch1a1 ==# ch2alt
      let retchar = ch1a2
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif

    " 一方が部品による足し算
    if lench1alt > 0 && lench2a1 > 0
      let retchar = s:BushuSearchCompose(ch1alt, ch2a1)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1alt > 0 && lench2a2 > 0
      let retchar = s:BushuSearchCompose(ch1alt, ch2a2)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a1 > 0 && lench2alt > 0
      let retchar = s:BushuSearchCompose(ch1a1, ch2alt)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a2 > 0 && lench2alt > 0
      let retchar = s:BushuSearchCompose(ch1a2, ch2alt)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif

    " 両方が部品による足し算
    if lench1a1 > 0 && lench2a1 > 0
      let retchar = s:BushuSearchCompose(ch1a1, ch2a1)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a1 > 0 && lench2a2 > 0
      let retchar = s:BushuSearchCompose(ch1a1, ch2a2)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a2 > 0 && lench2a1 > 0
      let retchar = s:BushuSearchCompose(ch1a2, ch2a1)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a2 > 0 && lench2a2 > 0
      let retchar = s:BushuSearchCompose(ch1a2, ch2a2)
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif

    " 部品による引き算
    if lench1a2 > 0 && lench2a1 > 0 && ch1a2 ==# ch2a1
      let retchar = ch1a1
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a2 > 0 && lench2a2 > 0 && ch1a2 ==# ch2a2
      let retchar = ch1a1
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a1 > 0 && lench2a1 > 0 && ch1a1 ==# ch2a1
      let retchar = ch1a2
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif
    if lench1a1 > 0 && lench2a2 > 0 && ch1a1 ==# ch2a2
      let retchar = ch1a2
      if s:BushuCharOK(retchar, char1, char2)
	return retchar
      endif
    endif

    " 文字の順を逆にしてやってみる
    let t = char1  | let char1  = char2  | let char2 = t
    let t = ch1alt | let ch1alt = ch2alt | let ch2alt = t
    let t = ch1a1  | let ch1a1  = ch2a1  | let ch2a1 = t
    let t = ch1a2  | let ch1a2  = ch2a2  | let ch2a2 = t
    let i = i + 1
  endwhile

  " 合成できなかった
  return ''
endfunction

"==============================================================================
"				  漢字テーブル

" 漢字テーブルファイルを開く
function! s:KanjiTable_FileOpen()
  if filereadable(s:kanjitable_file) != 1
    echo '漢字テーブルファイルが読めません: <' . s:kanjitable_file . '>'
    return
  endif
  if s:SelectWindowByName(s:kanjitable_file) < 0
    execute 'silent normal! :sv '.s:kanjitable_file."\<CR>"
  endif
  nnoremap <buffer> <silent> <CR> :<C-U>call <SID>KanjiTable_CopyChar()<CR>
  nnoremap <buffer> <silent> q :<C-U>quit<CR>
endfunction

" 漢字テーブルバッファから直近のバッファに漢字をコピーする
function! s:KanjiTable_CopyChar()
  let ch = matchstr(getline('.'), '\%' . col('.') . 'c.')
  execute "normal! \<C-W>pa" . ch . "\<ESC>\<C-W>p"
endfunction
