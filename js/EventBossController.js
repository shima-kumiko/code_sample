$(function() {

  'use strict';

  var mgc = window.jp.ameba.mgc_s;

  mgc.controllers.RaidBossDetailController = function() {
    this.initialize.apply(this, arguments);
  };

  mgc.controllers.RaidBossDetailController.prototype = mgc.extend(mgc.controllers.AbstController,{
    def: function(){
      // models ajax送信用
      this.support = new mgc.models.AbstModel('support','/$C/$P/ajax/$P-$T-$A');
      this._target = new mgc.models.AbstModel('target','/$C/$P/ajax/$P-$T-$A');

      // 救援回数と最大救援可能数
      this.supportRequeCount = 0;
      this.maxSupportRequeCount = 2;


      // おすすめターゲット情報
      this.useRecommend = mgc.data.isRecomendTarget;

      // おすすめtargetOrderを使用する場合
      if(this.useRecommend) {
        this.targetOrder = this.cloneList(mgc.data.recomendTargetOrder);
      }

      //レイドID
      this.raidId = mgc.data.raidId;
      //救援依頼時の最大表示数
      this.MAX_SUPPORT_DISPLAY = 10;
      //キャラと敵の関連情報保存配列(クローンを生成して参照先を変える)
      this.targetOrder = this.cloneList(mgc.data.targetOrder);



      //パーティ情報
      this.partyList = mgc.data.partyList;
      //取得パーティ番号
      this.selectedPartyIndex = 0;
      /**
        * @property commandStep
        * 0: ターゲット選択前
        * 1: 第一ターゲット選択時
        * 2: 第二ターゲット選択時
        **/
      this.commandStep = 0;
      /**
        * @property commandStatus
        * 'READY': ターゲット選択前
        * 'CHARACTER': 味方ターゲット選択時
        * 'ENEMY': 敵ターゲット選択時
        **/
      this.commandStatus = 'READY';
      // 現在選択中の味方の番号
      this.characterIndex = 0;
      // 現在選択中の敵の番号
      this.enemyIndex = this.targetOrder[0].enemy;;
      // 初回攻撃かどうか
      this.isFirstAttack = mgc.data.isFirstAttack;
      // 初回表示かどうか
      this.isFirstOpen = mgc.data.isFirstOpen;
      // レア子使者討伐報酬があるかどうか
      this.hasRareChildBossRewards = mgc.data.hasRareChildBossRewards;
      // レア子使者を含んでいるかどうか
      this.hasRareChildBoss = mgc.data.hasRareChildBoss;
      // ティッカー演出があるかどうか
      this.hasTickerInfo = mgc.data.hasTickerInfo;
      // ボス情報 [0]:ボス [1]:子使者1 [2]:子使者2 [3]:子使者3
      this.enemies = mgc.data.enemies;
      // プリロード画像格納用
      this.images = [];
      this.ANIMATION_END = 'animationend webkitAnimationEnd mozAnimationEnd webkitTransitionEnd transitionend';
      // 回復関連
      this.$useItemBtn = $('#js-useItemBtn');
      this.$recoveryItemModule = $('#js-recoveryItemModule');
      // コマンドウインドウ関連
      this.$commandModalBtn = $('#js-commandModalBtn');
      this.$setupTargetBtn = $('.js-setupTargetBtn');
      this.$commandWindow = $('#js-commandWindow');
      this.$enemies = $('.js-enemies');
      this.$targetLines = $('.js-targetLines');
      this.$enemyIcon = $('.js-enemyIcon');
      this.$enemyArrows = $('.js-enemyArrows');
      this.$submitSelectTarget = $('#js-submitSelectTarget');
      this.$cancelSelectTarget = $('#js-cancelSelectTarget');
      // ボスアニメーション関連
      this.$loading = $('#js-loading');
      this.$bossImage = $('#js-bossImage');
      this.$bossParts = $('#js-bossParts');
      this.$joinArea =$('.js-joinArea');
      // ターゲッティングアニメーション関連
      this.$targetMark = $('.js-targetMark');
      this.$markParts = $('.js-markParts');
      // パーティ選択modalボタン(初撃のみ)
      this.$selectPartyModalBtn = $('#js-selectPartyModalBtn');
      // 攻撃ボタン関連
      this.$fullAttackModal = $('#js-fullAttackModal');
      this.$drugAttackModal = $('#js-drugAttackModal');
      // 回復アイテム使用攻撃時DOM
      this.$recoveryAttack = $('#js-recoveryAttack');
      this.$drugUseAttack  = $('#js-drugUseAttack');
      // タブ関連 @js-render
      this.renderTabTmpl = [
        $('#js-tmpl_attackStatus'),
        $('#js-tmpl_attackMenbers'),
        $('#js-tmpl_getRewardList')
      ];
      this.$renderTabView = $('#js-renderTabView');
      this.$tab = $('.js-tab');
      // パーティ変更関連 @js-render
      this.$renderPartyTmpl = $('#js-tmpl_partyInfo');
      this.$renderPartyView = $('#js-renderPartyView');
      this.$closeModalBtn = $('.js-closeModalBtn');
      // 救援依頼関連 @js-render
      this.$renderSupportTmpl = $('#js-tmpl_supportList');
      this.$renderSupportView = $('#js-renderSupportView');
      this.$supportModal = $('#js-supportModal');
      this.$rescueBtn = $('#js-rescueBtn');
      // 救援ボタン
      this.$supportDetailModal = $('#js-supportDetailModal');
      this.$supportPersonBtn = $('#js-supportBtnPerson');
      this.$supportClubBtn = $('#js-supportBtnClub');
      // 攻撃ボタン関連@js-render
      this.$renderAttackBtnTmpl = $('#js-tmpl_attacBtns');
      this.$renderAttackBtnView = $('#js-renderAttackBtnView');
      // コマンド画面関連 @js-render
      this.$renderCommandPartyView = $('#js-renderCommandPartyView');
      this.$renderCommandPartyTmpl = $('#js-tmpl_commandPartyInfo');
      this.$guideText = $('#js-guideText');
      // レア子使者討伐報酬モーダル
      this.$rareBossRewardsModal = $('#js-rareBossRewardsModal');
      this.$rewardsModalCloseBtn = $('.js-rewardMdlCloseBtn');
      // 予想ゲージ
      this.$forcastGauge = $('.js-forcastGauge');
      // 前回の討伐結果のティッカー
      this.$infoTicker = $('.js-infoTicker');
      // レアボス出現カットイン
      this.$rareBossCutin = $('.js-rareBossAppearCutin');
      // おすすめターゲットボタン
      this.$recommendBtn = $('#js-recommenBtn');
      this.$recommendCheck = $('#js-recommendCheck');
    },
    /**
     * @constructor
     */
    init : function() {
      //ポップアップ用クラスの呼び出し
      this.recoveryModule = new mgc.controllers.CharacterRaidUseItemModule();
      //modalの準備
      $('#js-dlgArea>section').ambModalDlg();
      //パーティIDの設定
      this.setPartyIds();
      //ガイドメッセージ切り換え
      this.displayedGuideText();
      //アニメーション用画像のプリロード
      this.preload(0);
      //ページ下部コンテンツの遅延表示
      this.lazyRender();
      //ターゲッティングの更新
      this.updateTargetOrder();
      // おすすめターゲット設定時の処理
      if(this.useRecommend) {
        this.recommendTargetOn();
      }
    },
    /**
     * イベントの初期化
     */
    initEvents : function() {
      var that = this;
      // 初期タブの表示
      this.renderTabContent($(this.$tab[1]));
      //タブきりかえ
      this.$tab.on('click', function () {
        that.renderTabContent($(this));
      });
      //回復modal表示
      this.$useItemBtn.on('click', function () {
        that.recoveryModule.setItems();
        that.$recoveryItemModule.ambOpenModalDlg(false);
      });
      //パーティ選択modal表示
      this.$selectPartyModalBtn.on('click', function () {
        that.$renderPartyView.removeClass('c-state_hidden');
        that.renderPartyContent();

        // パーティ選択モーダル
        var partyInfo = that.getSelectedParty(that.selectedPartyIndex);
        if(that.isFirstAttack) {
          that.$renderPartyView.html(
            that.$renderPartyTmpl.render(partyInfo)
          );
        }
      });
      //全力攻撃modal表示
      this.$renderAttackBtnView.on('click', '#js-fullAttackBtn', function () {
        that.$fullAttackModal.ambOpenModalDlg(false);
      });
      //妙薬攻撃modal表示
      this.$renderAttackBtnView.on('click', '#js-drugAttackBtn', function () {
        that.$drugAttackModal.ambOpenModalDlg(false);
      });
      //コマンドウインドウ関連処理
      this.$renderCommandPartyView.on('click', '.js-characters', function () {
        that.selectCharacters($(this));
      });
      //敵ターゲットの選択
      this.$enemies.on('click', function () {
        that.selectEnemies($(this));
      });
      //コマンドウインドウ表示トリガー
      this.$setupTargetBtn.on('click', function () {
        //↓動的に取得している為、最初に定義出来ない↓
        var $characterArrows = $('.js-characterArrows'),
          partyInfo = that.getSelectedParty(that.selectedPartyIndex);

        if(partyInfo.isAttackPossible) {
          $characterArrows.removeClass('c-state_hidden');
          that.$joinArea.addClass('c-state_hidden');
          that.$commandWindow.removeClass('c-state_hidden');
          //表示情報の更新(ターゲッティング関連)
          that.updateTargetOrder();
        }
      });
      //選択コマンドの確定
      this.$submitSelectTarget.on('click', function () {
        that.$renderPartyView.addClass('c-state_hidden');
        that.$commandWindow.addClass('c-state_hidden');
        that.postPartyInfo();
      });
      //キャンセル処理
      this.$cancelSelectTarget.on('click', function () {
        // おすすめターゲットを解除
        that.recommendTargetOff();
        // ターゲットを初期値に修正
        that.targetOrder = that.cloneList(mgc.data.firstTargetOrder);
        that.$commandWindow.addClass('c-state_hidden');
        //表示情報の更新(ターゲッティング関連)
        that.updateTargetOrder();
        that.updateTargetStatus();
      });
      //パーティ設定modalのon/off
      this.$renderPartyView.on('click', '.js-closeModalBtn', function () {
        that.$renderPartyView.addClass('c-state_hidden');
      });
      //パーティ表示更新
      this.$renderPartyView.on('click', '#js-changePartyBtn', function () {
        that.selectedPartyIndex = that.getNextPartyIndex(that.selectedPartyIndex);
        that.renderPartyContent();
      });
      //救援依頼
      this.$rescueBtn.on('click', function () {
        that.$supportDetailModal.ambOpenModalDlg(false);
      });
      // おまかせで救援
      this.$supportPersonBtn.on('click', function () {
        that.postSupportRequest(0, $(this));
      });
      // ギルドに救援
      this.$supportClubBtn.on('click', function () {
        that.postSupportRequest(1, $(this));
      });
      // お任せターゲット切り替え
      this.$recommendBtn.on('click', function() {
        that.switchingRecommendTarget();
      });
    },
    /**
     * コマンドウィンドウ内の表示の初期化
     **/
    initCommandStatus: function () {
      if(this.commandStep < 2) {
        return;
      }
      var
        //↓動的に取得している為、最初に定義出来ない↓
        $charaIcon = $('.js-charaIcon'),
        $characterArrows = $('.js-characterArrows');

      //表示情報の更新
      $charaIcon.removeClass('target-effect');
      $charaIcon.removeClass('filter-alpha');
      $characterArrows.removeClass('c-state_hidden');
      this.$enemyIcon.removeClass('target-effect');
      this.$enemyIcon.removeClass('filter-alpha');
      this.$targetLines.removeClass('filter-alpha');
      this.$enemyArrows.addClass('c-state_hidden');
      //ターゲッティング情報の更新
      this.updateTargetOrder();
      //コマンドの選択状態
      this.commandStatus = 'READY';
      //コマンド選択の進行状態
      this.commandStep = 0;
      //ガイドメッセージ切り換え
      this.displayedGuideText();

      // おすすめターゲット設定時の処理
      if(this.useRecommend) {
        this.recommendTargetOn();
      }

    },
    /**
     * パーティIdを設定
     *  ex) id: "319_3_1" → userId: 319, partyType: 3, partyIndex: 1
     **/
    setPartyIds: function () {
      var i = 0,
        partyListSize = mgc.data.partyList.length;

      if(mgc.data.partyId !== null) {
        this.selectedPartyIndex = parseInt(mgc.data.partyId.split('_')[2], 10);
      } else {
        this.selectedPartyIndex = parseInt(mgc.data.partyList[0].partyId.split('_')[2], 10);
      }

      for(i = 0; i < partyListSize; i++) {
        mgc.data.partyList[i].userId = parseInt(mgc.data.partyList[i].partyId.split('_')[0], 10);
        mgc.data.partyList[i].partyType = parseInt(mgc.data.partyList[i].partyId.split('_')[1] ,10);
        mgc.data.partyList[i].partyIndex = parseInt(mgc.data.partyList[i].partyId.split('_')[2], 10);
      }
    },
    /**
     * 渡したパーティ番号の次のindex番号を返す
     * @param {Number} index パーティ番号
     * @return {Number} 渡したパーティ番号の次のindex番号
     **/
    getNextPartyIndex: function (index) {
      var i = 0,
        partyListSize = mgc.data.partyList.length,
        currentIndex;

      for(i = 0; i < partyListSize; i++) {
        if (index === mgc.data.partyList[i].partyIndex) {
          currentIndex = i + 1;
        }
      }
      if(currentIndex >= mgc.data.partyList.length) {
        currentIndex = 0;
      }

      return mgc.data.partyList[currentIndex].partyIndex;
    },
    /**
     * 選択中のパーティ情報を返す
     * @param {Number} index パーティ番号
     * @return {Object} 選択中のパーティ情報
     **/
    getSelectedParty: function (index) {
      var i = 0,
        partyListSize = mgc.data.partyList.length;

      for(i = 0; i < partyListSize; i++) {
        if(index === mgc.data.partyList[i].partyIndex) {
          return mgc.data.partyList[i];
        }
      }
    },
    /**
     * タブコンテンツのレンダリング
     *　@js-render
     * @param {JqueryDOMElement} $this 選択したタブのDOM
     **/
    renderTabContent: function ($this) {
      var that = this,
        index = $this.index('.js-tab');

      this.$tab.removeClass('c-tab__btn_type_1_selected');
      $this.addClass('c-tab__btn_type_1_selected');

      this.$renderTabView.html(
        that.renderTabTmpl[index].render()
      );
    },
    /**
     * パーティリストのレンダリング
     *　@js-render
     **/
    renderPartyContent: function () {
      var that = this,
        partyInfo = this.getSelectedParty(that.selectedPartyIndex);

      if(this.isFirstAttack) {
        that.$renderPartyView.on('click', '#js-changePartyBtn', function () {
          var nextPartyInfo = that.getSelectedParty(that.selectedPartyIndex);
          that.$renderPartyView.html(
            that.$renderPartyTmpl.render(nextPartyInfo)
          );
        });
      }


      this.$renderCommandPartyView.html(
        that.$renderCommandPartyTmpl.render(partyInfo, {useRecommend: this.useRecommend})
      );

      if(partyInfo.isAttackPossible) {
        this.$commandModalBtn.removeClass('filter-alpha');
        this.renderAttackBtnContent(false);
      } else {
        this.$commandModalBtn.addClass('filter-alpha');
        this.renderAttackBtnContent(true);
      }
    },
    /**
     * 攻撃ボタンのレンダリング
     *　@js-render
     * @param {Boolean} bool 攻撃可能かどうかのフラグ
     **/
    renderAttackBtnContent: function (bool) {
      var that = this,
        currentPartyId = this.getSelectedParty(that.selectedPartyIndex).partyId;

      this.$renderAttackBtnView.html(
        that.$renderAttackBtnTmpl.render({isDisabled: bool, partyId: currentPartyId})
      );


      // 回復アイテムを持っていれば遷移先を変更する
      if(this.$recoveryAttack.length >= 1) {
        this.$recoveryAttack.removeAttr('href');
        this.$recoveryAttack.attr('href', mgc.data.recoveryAttackUrl + '&partyId=' + currentPartyId);
      }


      // 妙薬を持っていれば遷移先を変更する
      if(this.$drugUseAttack.length >= 1) {
        this.$drugUseAttack.removeAttr('href');
        this.$drugUseAttack.attr('href', mgc.data.drugUseAttackUrl + '&partyId=' + currentPartyId);
      }

    },
    /**
     * 救援リストの生成と表示
     * @param {Object} data ajaxで受け取った救援情報
     **/
    renderSupportModal: function (data) {
      var that = this,
        supportList = [],
        i = 0,
        supportSize = data.length;

      that.supportRequeCount++;

      for( i = 0; i < supportSize; i++) {
        if(i < that.MAX_SUPPORT_DISPLAY) {
          supportList.push(data[i]);
        }
      }

      this.$renderSupportView.html(that.$renderSupportTmpl.render(supportList));
      that.$supportModal.ambOpenModalDlg(false);
      if(that.supportRequeCount >= that.maxSupportRequeCount){
        that.$rescueBtn.addClass('c-state_hidden');
      }
    },
    /**
     * コマンドウィンドウ内でキャラクター選択時の処理
     * @param {JqueryDOMElement} $this 選択したキャラクターのDOM
     **/
    selectCharacters: function ($this) {
      if(this.commandStatus === 'CHARACTER') {
        return;
      }
      // おすすめターゲットを解除
      this.recommendTargetOff();

      var that = this,
        //↓動的に取得している為、最初に定義出来ない↓
        $charaIcon = $('.js-charaIcon'),
        $characterArrows = $('.js-characterArrows');

      //コマンドの選択状態
      this.commandStatus = 'CHARACTER';
      //コマンド選択の進行状態
      this.commandStep ++;
      //選択中のキャラクターの番号
      this.characterIndex = $this.index();
      //表示情報の更新
      $charaIcon.removeClass('target-effect');
      this.$enemyIcon.removeClass('target-effect');
      this.$targetLines.addClass('filter-alpha');
      $characterArrows.addClass('c-state_hidden');
      this.$enemyArrows.removeClass('c-state_hidden');
      this.$enemyIcon.removeClass('filter-alpha');
      $charaIcon.addClass('filter-alpha');
      $charaIcon.eq(that.characterIndex).removeClass('filter-alpha');
      $charaIcon.eq(that.characterIndex).addClass('target-effect');
      this.$targetLines.eq(that.characterIndex).removeClass('filter-alpha');
      //ガイドメッセージ切り換え
      this.displayedGuideText();
      //コマンドウィンドウ内の表示の初期化
      this.initCommandStatus();
    },
    /**
     * コマンドウィンドウ内で敵を選択時の処理
     * @param {JqueryDOMElement} $this 選択した敵のDOM
     **/
    selectEnemies: function ($this) {
      if(this.enemies[$this.index()].currentHp === 0 || this.commandStatus === 'ENEMY') {
        return;
      }

      // おすすめターゲットを解除
      this.recommendTargetOff();

      var that = this,
        //↓動的に取得している為、最初に定義出来ない↓
        $charaIcon = $('.js-charaIcon'),
        $characterArrows = $('.js-characterArrows'),
        i = 0,
        targetOrderSize = this.targetOrder.length;

      //コマンドの選択状態
      this.commandStatus = 'ENEMY';
      //コマンド選択の進行状態
      this.commandStep ++;
      //選択中の敵の番号
      this.enemyIndex = $this.index();
      //表示情報の更新
      $charaIcon.removeClass('target-effect');
      this.$enemyIcon.removeClass('target-effect');
      this.$targetLines.addClass('filter-alpha');
      for(i = 0; i < targetOrderSize; i++) {
        if(this.enemyIndex === this.targetOrder[i].enemy) {
          this.$targetLines.eq(this.targetOrder[i].chara).removeClass('filter-alpha');
        }
      }
      this.$enemyArrows.addClass('c-state_hidden');
      $characterArrows.removeClass('c-state_hidden');
      this.$enemyIcon.addClass('filter-alpha');
      this.$enemyIcon.eq(that.enemyIndex).removeClass('filter-alpha');
      this.$enemyIcon.eq(that.enemyIndex).addClass('target-effect');
      //ガイドメッセージ切り換え
      this.displayedGuideText();
      //コマンドウィンドウ内の表示の初期化
      this.initCommandStatus();
    },
    /**
     *　コマンド選択情報の更新
     **/
    updateTargetOrder: function () {
      var that = this,
        i = 0,
        targetOrderSize = this.targetOrder.length,
        lineIndex = 0;


      // おすすめの場合はターゲットを上書き
      if(that.useRecommend) {
        this.targetOrder = this.cloneList(mgc.data.recomendTargetOrder);
      }else {
        //サーバー側に渡す情報の更新
        this.targetOrder[that.characterIndex].chara = this.characterIndex;
        this.targetOrder[that.characterIndex].enemy = this.enemyIndex;
      }

      for(i = 0; i < targetOrderSize; i++) {
        if(this.enemies[that.targetOrder[i].enemy].currentHp <= 0) {
          that.targetOrder[i].enemy = 0;
        }
        //ターゲットラインの表示更新
        if(this.$targetLines.eq(that.targetOrder[i].chara).attr('class').search(/line-select-type/)) {
          lineIndex = this.$targetLines.eq(that.targetOrder[i].chara).attr('class').split('line-select-type')[1];
        }
        this.$targetLines.eq(that.targetOrder[i].chara).removeClass('line-select-type' + lineIndex);
        this.$targetLines.eq(that.targetOrder[i].chara).addClass('line-select-type_' + that.targetOrder[i].chara + '_' + that.targetOrder[i].enemy);
      }
      //予想ダメージ表示
      this.updateForcastStatus();
    },
    /**
     * 予想ダメージ状態更新
     **/
    updateForcastStatus: function () {
      var that = this,
        i = 0,
        j = 0,
        characterList = this.getSelectedParty(that.selectedPartyIndex).characterList,
        enemiesHp = [],
        currentHp = 0,
        enemiesRace = [],
        raceId = 0,
        barPos = 0,
        currentRatio = 0,
        enemyHpRatio = 0;

      //ゲージの表示を初期化
      this.$forcastGauge.css('width', 0 + '%');
      for( i = 0; i < this.enemies.length; i++) {
        currentHp = this.enemies[i].currentHp;
        enemiesHp.push(currentHp);
        raceId = this.enemies[i].raceId;
        enemiesRace.push(raceId);
      }

      for( j = 0; j < this.targetOrder.length; j++) {
        // 予想ダメージを計算。（選択したradeIdを計算に含む。）
        var targetRaceId = enemiesRace[that.targetOrder[j].enemy];
        enemiesHp[that.targetOrder[j].enemy] -= characterList[that.targetOrder[j].chara].afterRating[targetRaceId];

        enemyHpRatio = Math.floor(this.enemies[that.targetOrder[j].enemy].currentHp / that.enemies[that.targetOrder[j].enemy].maxHp * 100);

        barPos = 100 - enemyHpRatio;

        if(enemiesHp[that.targetOrder[j].enemy] <= 0) {
          enemiesHp[that.targetOrder[j].enemy] = 0;
          currentRatio = 100 - Math.floor(enemiesHp[that.targetOrder[j].enemy] / that.enemies[that.targetOrder[j].enemy].currentHp * 100);
        } else {
          currentRatio = 100 - Math.floor(enemiesHp[that.targetOrder[j].enemy] / that.enemies[that.targetOrder[j].enemy].currentHp * 100);
        }

        currentRatio = (currentRatio / 100) * enemyHpRatio;

        if(barPos >= 1) {
          barPos = barPos - 1;
        }

        this.$forcastGauge.eq(that.targetOrder[j].enemy).css('width', currentRatio + '%');
        this.$forcastGauge.eq(that.targetOrder[j].enemy).css('right', (barPos) + '%');
      }
    },
    /**
     *ターゲッティングの更新
     **/
    updateTargetStatus: function (order) {
      var that = this,
        targetOrderSize = this.targetOrder.length,
        i = 0;

      this.$targetMark.removeClass('c-state_hidden');
      this.$targetMark.addClass('c-state_hidden');
      that.$joinArea.empty();

      if(order === null) {// 指定がされた場合は updateTargetOrderを起動しない。
        this.updateTargetOrder();
      }

      for(i = 0; i < targetOrderSize; i++) {
        if(this.$targetMark.eq(that.targetOrder[i].enemy).attr('class').search(/c-state_hidden/) === false) {
          return;
        }
        this.animateMarker(i);
      }
    },
    /**
    * ボス出現演出をひとまとめにしたもの
    *
    **/
    appearEnemyTeam: function() {
      var that = this;
      that.$bossImage
        .addClass('slide-from-top')
        .on(that.ANIMATION_END, function () {
          $(this).off(that.ANIMATION_END);
          that.$bossImage.removeClass('slide-from-top');
        });

      that.$bossParts
        .addClass('slide-from-bottom')
        .on(that.ANIMATION_END, function () {
          $(this).off(that.ANIMATION_END);
          that.$bossParts.removeClass('slide-from-bottom');

          // 攻撃ボタンの可否判断
          that.renderPartyContent();

          // ティッカーを起動
          that.tickerInfoAppear();
        });
    },
    /**
    * ティッカー演出
    *
    **/
    tickerInfoAppear: function () {
      var that = this;

      // 攻撃ボタンの可否判断
      that.renderPartyContent();

      // ティッカー演出がない場合はなにもしない
      if(that.hasTickerInfo == false) {
        // ターゲット更新処理（演出含む）実行
        that.updateTargetStatus();
        return;
      }

      that.$infoTicker.removeClass('c-state_hidden').addClass('info-ticker_ani')
        .on(that.ANIMATION_END, function () {
          $(this).off(that.ANIMATION_END).remove();
          // ターゲット更新処理（演出含む）実行
          that.updateTargetStatus();
        });
    },
    /**
    * レア子使者登場カットイン
    *
    **/
    rareChildBossCutIn: function() {
      var that = this;
      that.$rareBossCutin.removeClass('c-state_hidden')
        .on(that.ANIMATION_END, function () {
          $(this).off(that.ANIMATION_END).remove();
          that.appearEnemyTeam();
        });
    },
    /**
     *コマンドウインドウでのガイドメッセージの表示きりかえ
     *
     **/
    displayedGuideText: function () {
      var that = this;
      this.$guideText.empty().html(mgc.data.guideMessage[that.commandStatus]);
    },
    /**
     * プリロード完了後のコールバック処理
     **/
    loadComplete: function () {
      var that = this;
      this.$loading.addClass('c-state_hidden');
      this.$bossImage.removeClass('c-state_hidden');
      this.$bossParts.removeClass('c-state_hidden');

      // 状況に応じて再生する演出に変化を持たせる。
      if(this.hasRareChildBossRewards) {
        // レア子使者討伐報酬がある場合はモーダルを最優先で表示
        that.$rareBossRewardsModal.ambOpenModalDlg(true);
        that.$rareBossRewardsModal.ambOpenModalDlg('close', null, that.tickerInfoAppear());

        that.$rewardsModalCloseBtn.on('click', function(){
          that.$rareBossRewardsModal.ambCloseModalDlg(false);
        });
      }else if((this.isFirstOpen) && (this.hasRareChildBoss)) {
        // レア使者を含んだ初回表示でカットインを起動
        that.rareChildBossCutIn();
      }else if (this.isFirstAttack) {
        // 初回表示でボスの出現を起動
        that.appearEnemyTeam();
      }else {
        // 2回目以降の表示でターゲッティングを表示
        that.tickerInfoAppear();
      }
    },
    /**
     * 遅延読み込み
     * @ lazyLoad.js
     **/
    lazyRender: function() {
      var that = this;
      $(window).scroll(function() {
        mgc.lazyScroll(
            that.$renderTabView,
            function() {
              that.renderTabContent(that.$tab.eq(0));
            }
        );
      });
    },
    /**
     * post @ajax
     * 救援依頼の送信（supportType = 0 がおまかせ、1がギルド）
     **/
    postSupportRequest: function (supportType, _this) {
      var that = this;

      this.support.post({
        beforeSend: function(){
        },
        complete: function(){
        },
        success: $.proxy(function(data){
          that.renderSupportModal(data);
          _this.attr('disabled', 'disabled');
        }, that),
        appError: $.proxy(function(){
        }, that),
        category: 'event',
        phase: 'raid', //AbstModelで生成するAjaxのURLに使用する。
        data: {
          raidId: that.raidId,
          destination: supportType
        }
      });
    },
    /**
     * post @ajax
     * 攻撃パーティ情報の送信
     **/
    postPartyInfo : function() {
      var that = this,
        targetData = '',
        i = 0;

      for (i = 0; i < this.targetOrder.length; i++) {
        if(i !== 0) {
          targetData = targetData + ',' + that.targetOrder[i].enemy;
        } else {
          targetData = targetData + that.targetOrder[i].enemy;
        }

      }
      //ajaxでパーティーを取得
      this._target.post({
        beforeSend: function(){
        },
        complete: function(){

        },
        success: $.proxy(function(){
          mgc.data.targetOrder = that.cloneList(that.targetOrder);
          mgc.data.firstTargetOrder = that.cloneList(that.targetOrder);
          that.updateTargetStatus();
        }),
        appError: $.proxy(function(){
        }, that),
        category: 'event',
        phase: 'raid',
        data: {
          raidId: that.raidId,
          requestList: targetData,
          useRecommendBossTarget: that.useRecommend
        }
      });
    },
    /**
    * おすすめターゲットの切り替え
    **/
    switchingRecommendTarget: function() {
      // おすすめターゲット → 通常ターゲット
      if(this.useRecommend) {
        this.recommendTargetOff();
      }else{
        this.recommendTargetOn();
      }
    },
    recommendTargetOff: function() {
      this.useRecommend = false;
      this.$recommendCheck.removeClass('check_on').addClass('check_off');

      // 矢印と画面の光彩を下げる
      var $charaIcon = $('.js-charaIcon'),
          $characterArrows = $('.js-characterArrows');
      $characterArrows.removeClass('c-state_hidden');
      $charaIcon.removeClass('filter-alpha');
      this.$enemyIcon.removeClass('filter-alpha');

      //コマンドの選択状態
      this.commandStatus = 'READY';
      //ガイドメッセージ切り換え
      this.displayedGuideText();
    },
    recommendTargetOn: function() {
        this.useRecommend = true;
        this.$recommendCheck.removeClass('check_off').addClass('check_on');

        // 矢印と画面の光彩を下げる
        var $charaIcon = $('.js-charaIcon'),
            $characterArrows = $('.js-characterArrows');
        $characterArrows.addClass('c-state_hidden');
        $charaIcon.addClass('filter-alpha');
        this.$enemyArrows.addClass('c-state_hidden');
        this.$enemyIcon.addClass('filter-alpha');

        //コマンドの選択状態
        this.commandStatus = 'AUTO';
        //ガイドメッセージ切り換え
        this.displayedGuideText();

        this.updateTargetOrder();
    },

    /**
     *ターゲッティング表示のアニメーション
     **/
    animateMarker: function (i) {
      var that = this;

      setTimeout(function () {
          that.$joinArea.eq(that.targetOrder[i].enemy).append(mgc.data.charaImages[that.targetOrder[i].chara]);

          that.$targetMark.eq(that.targetOrder[i].enemy).removeClass('c-state_hidden');

          that.$targetMark.eq(that.targetOrder[i].enemy)
            .addClass('animate-rotation')
            .on(that.ANIMATION_END, function () {
              $(this).off(that.ANIMATION_END);
              $(this).removeClass('animate-rotation');
              that.$joinArea.removeClass('c-state_hidden');
            });

          that.$targetMark.eq(that.targetOrder[i].enemy).find(that.$markParts).each(function(index) {
              $(this)
                .addClass('animate-mark_' + index)
                .on(that.ANIMATION_END, function () {
                  $(this).off(that.ANIMATION_END);
                  $(this).removeClass('animate-mark_' + index);
                  if(index >= 3) {
                    setTimeout(function() {
                      that.renderPartyContent();
                    }, 500);
                  }
                });
            });
        }, 80 * i);
    },
    /**
     * アニメーションさせるボス関連の画像のプリローディング
     * @param {Number} num プリロードを開始する配列のインデックス
     **/
    preload: function (num) {
      var that = this,
        manifest = mgc.data.manifest;

      that.images[num] = new Image();
      that.images[num].src = manifest[num].src;
      that.images[num].width = manifest[num].width || 0;

      that.images[num].onload = function() {
        that.images[num].onload = null;
        $('#' + manifest[num].id).append(that.images[num]);
        if (num < manifest.length -1) {
          that.preload(num + 1);
        } else {
          that.loadComplete();
        }
      };
      that.images[num].onerror = function() {
        if (num < manifest.length -1) {
          that.preload(num + 1);
        } else {
          that.loadComplete();
        }
      };
    },
    /**
     * 配列のクローンを生成する(かなり限定的な処理の為、他ではそのまま使わないこと)
     * @parama {Array} list  クローンを生成したい配列
     * @return {Array} 配列のクローン
     **/
    cloneList: function (list) {
      var clone = [],
        i = 0,
        listSize = list.length,
        key;

      for (i = 0; i < listSize; i++) {
        clone[i] = {};
        for(key in list[i]) {
          if (list[i].hasOwnProperty(key)) {
            clone[i][key] = list[i][key];
          }
        }
      }
      return clone;
    },
  });
});
