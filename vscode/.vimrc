noremap H _
noremap L $
noremap J <C-f>
noremap K <C-b>

inoremap jj <Esc>

nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap Y y$
nnoremap <Up> :<C-p>
nnoremap <CR> o<ESC>

" カーソルのある位置だけ folding を開く、それ以外を閉じる
nnoremap zh zMzv


" ----------------+--------+--------+--------+----------+--------+---------+--------------.
"  Commands\Modes | Normal | Visual | Select | Operator | Insert | Command | Others       |
" ----------------+--------+--------+--------+----------+--------+---------+--------------|
"  map            |   @    |   @    |   @    |    @     |        |         |              |
"  nmap           |   @    |        |        |          |        |         |              |
"  vmap           |        |   @    |   @    |          |        |         |              |
"  smap           |        |        |   @    |          |        |         |              |
"  xmap           |        |   @    |        |          |        |         |              |
"  omap           |        |        |        |    @     |        |         |              |
" ----------------+--------+--------+--------+----------+--------+---------+--------------|
"  map!           |        |        |        |          |   @    |    @    |              |
"  imap           |        |        |        |          |   @    |         |              |
"  lmap           |        |        |        |          |   @    |    @    | Lang-Arg     |
"  cmap           |        |        |        |          |        |    @    |              |
"  tmap           |        |        |        |          |        |         | terminal Job |
" ----------------+--------+--------+--------+----------+--------+---------+--------------.
