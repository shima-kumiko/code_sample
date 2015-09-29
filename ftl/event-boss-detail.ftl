<#assign ftlFilePath = "${.template_name}" />
<#compress>
<!DOCTYPE html>
<html lang="ja">
<head>
	<#--metaタグ、CSSのインポート-->
	<#include "/WEB-INF/content/common/htmlHead.ftl">
</head>

<body>
	<#include "/WEB-INF/content/common/pc-header-content.ftl">
	<#assign itemType = enums["jp.ameba.game.magic.core.enums.db.global.Type"] />
	<div id="global-wrapper" class="c-wrapper">
		<#--ヘッダのインクルード-->
		<#include "/WEB-INF/content/common/header.ftl">

		<#assign parentBoss = parentBossInfo.MRaidBoss><#--親のボス情報-->
		<#assign parentBossDetail = parentBossInfo.MRaidBossDetail><#--親のボス詳細情報-->
		<#assign currentBp = battlePointInfo.battlePoint><#--現在のBP-->
		<#assign maxBp = battlePointInfo.maxBattlePoint><#--最大BP-->

		<#----
		レイドボス種別の判別：

		1001 は通常使者
		10001, 100001    は特大使者となります。
		------>

		<#if parentBossDetail.bossDetailId == 1001 && !(started2nd)>
			<#assign bossBgType = 1>
		<#elseif parentBossDetail.bossDetailId == 1001 && started2nd>
			<#assign bossBgType = 3>
		<#elseif !(started2nd)>
			<#assign bossBgType = 2>
		<#elseif started2nd>
			<#assign bossBgType = 4>
		</#if>

		<#-- レア子使者の名称 -->
		<#assign rareChildBossName = "王トロル">

		<#-- レア子使者が含まれるかどうかの判別 -->
		<#assign hasRareChildBoss = false>

		<#-- レア子使者の状態を更新（！レア子使者複数対応の場合は要改修） -->
		<#assign isRareChildStatus = 0>
		<#list childBossInfos as childboss>
			<#assign childInfo = childboss.MRaidBoss>

			<#-- isRareChildStatus　通常: 0　撃破: 1　逃亡: 2 -->
			<#if childInfo.additionalType == 1>
				<#assign rareBossCurrentHp = childboss.currentHitPoints>

				<#if childboss.escapeDatetime?has_content>
					<#assign rareBossCurrentHp = 0>
					<#assign isRareChildStatus = 2>
				<#elseif (childboss.currentHitPoints <= 0)>
					<#assign isRareChildStatus = 1>
				</#if>
			</#if>
		</#list>



		<#--全力攻撃可能かどうか-->
		<#if currentBp == maxBp>
			<#assign fullyRecoverd = true>
		<#else>
			<#assign fullyRecoverd = false>
		</#if>

		<#--
			#ソーマの所持状況
			全力攻撃時にどれを優先して使うかを判定
			useType 0: 未所持
				1: 通常ソーマ
				2: 自ソーマ
				3: 当日用ソーマ
				4: ハーフソーマ
		-->
			<#--ハーフソーマ所持-->
		<#if (currentBp > 2) && (powerRegenMyselfHalfItemCount > 0)>
			<#assign useType = 4>
			<#assign useItemName = powerRegenMyselfHalfItem.name!?html>
			<#assign useItemId = powerRegenMyselfHalfItem.itemId!?html>
			<#assign useItemRemainCount = powerRegenMyselfHalfItemCount>
		<#else>
			<#-- 当日用ソーマ所持 -->
			<#if (0 < powerRegenOneDayItemCount)>
			<#assign useType = 3>
			<#assign useItemName = powerRegenOneDayItem.name!?html>
			<#assign useItemId = powerRegenOneDayItem.itemId!?html>
			<#assign useItemRemainCount = powerRegenOneDayItemCount>
			<#-- 自分用ソーマ所持 -->
			<#elseif (0 < powerRegenMyselfItemCount)>
			<#assign useType = 2>
			<#assign useItemName = powerRegenMyselfItem.name!?html>
			<#assign useItemId = powerRegenMyselfItem.itemId!?html>
			<#assign useItemRemainCount = powerRegenMyselfItemCount>
			<#--通常ソーマ所持-->
			<#elseif (0 < powerRegenItemCount)>
			<#assign useType = 1>
			<#assign useItemName = powerRegenItem.name!?html>
			<#assign useItemId = powerRegenItem.itemId>
			<#assign useItemRemainCount = powerRegenItemCount>
			<#--ソーマ未所持-->
			<#else>
			<#assign useType = 0>
			<#assign useItemName = powerRegenItem.name!?html>
			<#assign useItemId = powerRegenItem.itemId>
			<#assign useItemRemainCount = 0>
			</#if>
		</#if>

		<div id="global-container" class="c-container character-raid-container">
			<#include "/WEB-INF/content/event/raid/include/raid-command-window.ftl">

			<#--
			###ボスの名前領域
			-->
			<div class="detail-boss-name c-flex c-flex-pack_justify c-m5_t">
				<div class="c-flex c-p10_l">
					<p class="text-deco_black">${parentBossDetail.name!?html}</p>
					<p class="c-p10_l">Lv.${parentBossInfo.level!?html}</p>
				</div>
				<div class="c-flex c-m10_r c-fs_s detail-boss-escapetime">
					<p>逃亡まで</p>
					<#if endMinutes?string?length == 1>
						<#assign remainMinutes = "0" + endMinutes?string>
					<#else>
						<#assign remainMinutes = endMinutes?string>
					</#if>
					<#if endSeconds?string?length == 1>
						<#assign remainSeconds = "0" + endSeconds?string>
					<#else>
						<#assign remainSeconds = endSeconds?string>
					</#if>
					<p id="js-restTime" class="c-fc_rd c-p10_h c-m5_l text-deco_box_black">${remainMinutes!?html}:${remainSeconds!?html}</p>
				</div>
			</div><#--end detail-boss-name-->
			<#--
			##ボス情報表示
			-->
			<div class="boss-detail">
				<section class="js-rareBossAppearCutin rare-boss-cutin c-state_hidden">
					<div class="rare-cutin-obj cutin_base"></div>
					<div class="rare-cutin-obj cutin_avatar"></div>
					<div class="rare-cutin-obj cutin_text"></div>
					<div class="rare-cutin-obj cutin_effect"></div>
				</section>
				<#--
					###初回ポップアップ
				-->
				<div id="js-renderPartyView">
				</div>
				<#--
					###親ボス画像
				-->
				<figure id="js-bossBgImage"class="detail-boss-img"></figure>
				<figure id="js-bossImage" class="js-setupTargetBtn detail-boss-img c-state_hidden"></figure>

				<#--
					###ボスステータス表示領域
				-->
				<div class="boss-status">
					<div class="c-flex">
						<div class="c-icon-race c-icon-race_size_n c-icon-race_type_${parentBoss.raceId!?html} bg-shadow_circle_0"></div>
						<p class="c-p5_t text-deco_black">
							<#if bossType == 2>強力</#if>使者：<span class="c-fc_yl">${parentBossInfo.currentHitPoints?string(",###")}</span>&nbsp;/&nbsp;${parentBossInfo.maxHitPoints?string(",###")}
						</p>
					</div>
					<div class="c-gauge c-gauge_type_5 boss-status__gauge bg-shadow_box">
						<div class="c-gauge__bar c-gauge__bar_col_gn" style="width:${parentBossInfo.currentHitPoints / parentBossInfo.maxHitPoints * 100}%"></div>
					</div>
				</div><#--[end] boss-status-->
				<#--
					###ボス部位表示
				-->
				<div id="js-bossParts" class="c-flex c-flex-pack_justify c-p10_h boss-parts c-state_hidden">
					<#list childBossInfos as childboss>
						<#assign childInfo = childboss.MRaidBoss>

						<#-- 子使者がレアかどうかの判定 -->
						<#if childInfo.additionalType == 1>
							<div class="js-setupTargetBtn  boss-parts__unit enemies-target">
								<div class="boss-status">
									<p class="c-fs_xs text-deco_black c-p5_l">${rareChildBossName!?html}</p>
									<div class="c-gauge c-gauge_type_3 gauge-select-boss gauge-select-size_l gauge-select-boss_type_${childInfo.raceId!?html} c-m30_l bg-shadow_box bg-shadow_circle_1">
										<div class="c-gauge__bar c-gauge__bar_col_gn" style="width:${rareBossCurrentHp / childboss.maxHitPoints * 100}%"></div>
									</div>
								</div>
								<figure id="js-bossParts${childboss_index + 1}"></figure>
							</div>
							<#assign hasRareChildBoss = true>
						<#else>
							<div class="js-setupTargetBtn  boss-parts__unit enemies-target">
								<div class="boss-status">
									<p class="c-fs_xs text-deco_black c-p5_l">子使者${(childboss_index + 1)!?html}</p>
									<div class="c-gauge c-gauge_type_3 gauge-select-boss gauge-select-size_l gauge-select-boss_type_${childInfo.raceId!?html} c-m30_l bg-shadow_box bg-shadow_circle_1">
										<div class="c-gauge__bar c-gauge__bar_col_gn" style="width:${childboss.currentHitPoints / childboss.maxHitPoints * 100}%"></div>
									</div>
								</div>
								<figure id="js-bossParts${childboss_index + 1}"<#if childboss.currentHitPoints == 0> class="filter-alpha"</#if>></figure>
							</div>
						</#if>
					</#list>
				</div><#--[end] boss-parts-->
				<#--
					###リロードボタン
				-->
				<div class="detail-boss-reload">
					<a class="c-btn c-btn_type_1 c-btn_col_gr c-btn_size_square_s detail-boss-reload__marker" href="${urlContext!?html}/event/raid/boss-detail?raidId=${raidId!?html}"></a>
				</div>

				<#--
					###仲間ボーナスアイコン
				-->

				<#if (stealthEffect.effectId)?has_content>
					<div class="box-character-bonus c-flex">
						<div class="box-character-bonus__inner">
							<i class="text-character-bonus text-character-bonus_${(stealthEffect.effectRate - 100)!?html}"></i>
							<#assign min = "0" + stealthEffect.remainMinutes>
							<#assign sec = "0" + stealthEffect.remainSeconds>
							<p class="box-character-bonus__time c-fc_rd c-fs_xs">あと${min[min?length-2..min?length-2] + min[min?length-1..min?length-1]!?html}:${sec[sec?length-2..sec?length-2] + sec[sec?length-1..sec?length-1]!?html}</p>
						</div>
					</div>
				</#if>

				<#--
					###ティッカー表示箇所
				-->
				<#if result?has_content>
					<div class="js-infoTicker info-ticker c-fs_s c-p5_v c-state_hidden">
						<#-- ダメージと獲得ptの表示 -->
						<p><span class="c-fc_yl">${result.damageSum?string(",###")}</span> のダメージを与えた！</p>
						<p>獲得討伐pt <span class="c-fc_yl">${result.gotPoint?string(",###")}pt</span></p>
						<#-- 王トロルステータス表示 -->
						<p class="c-fc_rd c-m5_t">
							<#if runAway?has_content && runAway>
								${rareChildBossName!?html}は逃亡した...
							<#elseif specialBossSubduedUserRelation?has_content>
								${rareChildBossName!?html}を撃破！
							</#if>
						</p>
						<#-- 救援ユーザの表示 -->
						<#if memberInfos?has_content>
							<#list memberInfos as member>
								<#-- 発見者以外で member.attackCount が 1 且つ、member.elapsedTime が一定時間以内（1分間）のユーザ -->
								<#if !(member.findFlg) && (member.userId != iUser.userId) && (member.attackCount == 1) && (member.elapsedTime < 60000)>
									<p><span class="c-fc_yl"><@shortName '${member.name}'/></span>が救援に駆けつけた！</p>
									<#break>
								</#if>
							</#list>
						</#if>
					</div>
				</#if>
				<#--
					###ターゲットアイコン
				-->
				<#list partyIds as currentId>
					<div class="js-targetMark target-mark target-mark_type_${currentId_index} c-state_hidden">
						<#list partyCharacterListMap.get(currentId) as partyInfo>
							<i class="js-markParts icon-mark icon-mark_type_${partyInfo_index}"></i>
						</#list>
						<div class="js-joinArea join-characters c-flex c-state_hidden">
						</div>
					</div>
				</#list>
				<#--
					###ボス画像
				-->
				<div id="js-loading" class="c-flex c-p30_t">
					<div class="icon-loading"></div>
				</div>
			</div><#--[end] boss-detail-->
			<#--
				##パーティ選択modal表示ボタン(初撃のみ)
			-->
			<#if firstFlg>
				<div class="select-party">
					<a id="js-selectPartyModalBtn" class="select-party__btn"></a>
				</div>
			</#if>

			<#--
			##使者選択表示
			-->
			<div class="setup-target">
				<div class="setup-target__inner">
					<a id="js-commandModalBtn" class="js-setupTargetBtn setup-target__btn"></a>
					<div class="icon-bg_commandbtn"></div>
				</div>
			</div>

			<#--
			##ボタン周り(攻撃、救援) 初期表示はダミー
			-->
			<div class="c-flex c-flex-pack_start c-p10_h boss-btn-area">
				<div id="js-renderAttackBtnView" class="c-flex c-flex-pack_start">
					<#if supportAttackFlg>
						<#--
							###救援時初回消費AP0
						-->
						<div>
							<a class="updateEvt updateEvt btn-attack btn-attack_free filter-alpha" disabled=disabled></a>
						</div>
					<#else>
						<#--
							###通常攻撃
						-->
						<div>
							<a class="btn-attack_event btn-attack_normal filter-alpha" disabled=disabled></a>
						</div>
						<#--
							###全力攻撃
						-->
						<div class="c-p5_l c-p15_b">
							<p class="c-fs_xs">ダメージ<span class="c-fc_yl">8</span>倍</p>
							<#--BP全快時-->
							<a class="btn-attack_event btn-attack_full filter-alpha" disabled=disabled></a>
						</div>
						<#---
							###妙薬攻撃
						-->
						<div class="c-p15_b">
							<p class="c-fs_xs">ダメージ<span class="c-fc_yl">16</span>倍</p>
							<a class="btn-attack_event btn-attack_drug filter-alpha" disabled=disabled></a>
						</div>
					</#if>
				</div>
				<#--
					##救援依頼ボタン
				-->
				<div class="c-p5 btn-on-list">
					<#-- iRaid.rescueStatus[0:未依頼 1:ギルメン済み 2:おまかせ済み 3:両方済み]  -->
					<#if (iRaid.rescueStatus != 3) && (iRaid.findUserId == iUser.userId) && !firstFlg>
						<a id="js-rescueBtn" class="rescue-btn rescue-btn_on"></a>
					</#if>
					<div class="rescue-btn rescue-btn_off c-fs_s">
						<p class="c-p5_t">
							討伐<br>メンバー<br>
							<span class="c-fc_yl">${memberInfos?size}人</span>
						</p>
					</div>
				 </div>
				</div><#--end ##救援依頼ボタン -->

				<#--
				<#if firstFlg && supportAttackFlg == false && iUser.userId != findUserId>
					<p class="c-p5_b">あと<span class="c-fc_yl">${battlePointInfo.freeAttackIntervals!?html}</span>で救援初回攻撃が消費BP0！</p>
				</#if>
				-->
				<#--
					##BP表示領域
				-->
				<div class="c-flex">
					<div class="c-flex c-flex-pack_start c-p15_r raid-bp-status">
						<div class="c-flex c-p30_l c-fs_s raid-bp-status__count">
							<p>BP</p>
							<p class="c-p20_l">
								<#list 1..maxBp as i>
									<#if (currentBp >= i) >
										<img src="${statURL!?html}/img/character/raid/icon-bp.png" width="13" height="14">
									<#else>
										<img src="${statURL!?html}/img/character/raid/icon-bp_empty.png" width="13" height="14">
									</#if>
								</#list>
							</p>
						</div>
						<div class="c-fs_xs c-p20_l">
							<span>1回復</span>
							<span class="c-fc_yl">${battlePointInfo.remainTime!?html}</span>
						</div>
						<#--
						####BP回復modalを開くボタン
						-->
						<div>
							<a id="js-useItemBtn" class="c-fs_s raid-bp-status__btn bp-recover-btn"></a>
						</div>
					</div>
				</div>

			<#--
			##簡易遷移リスト
			-->
			<div class="c-flex c-flex-pack_justify c-p15_h c-p20_t c-p10_b">
				<a class="c-btn c-btn_type_2 c-btn_col_bl_texture c-btn_size_xs c-fs_n" href="${urlContext!?html}/character-raid-status">討伐一覧</a>
				<a class="c-btn c-btn_type_2 c-btn_col_bl_texture c-btn_size_xs c-fs_n" href="${urlContext!?html}/event/raid/quest">クエスト</a>
			</div>
			<#--
			##簡易討伐状況
			-->
			<div class="c-p15_h c-p5_t">
				<div class="c-box c-box_type_1 c-box_col_border_gr c-box_rounded_5 c-fs_s">
					<div class="c-flex">
						<p class="c-p5_h"><span class="c-fc_yl">討伐中：</span> ${entryCount!?html} / ${maxEntry!?html}件</p>
						<p class="c-p5_h"><span class="c-fc_yl">救援依頼：</span>${requestCount!?html}件</p>
					</div>
				</div>
			</div>

			<#--
			##ボーダー下部
			-->
			<div class="c-flex c-p20_t">
				<div class="raid-border raid-border_top"></div>
			</div>


			<#---
				有利カード・子使者ボーナス表示
			-->
			<div class="effective-info-box c-box_type_1 c-box_col_bl c-m10_t c-m5_h c-p10_v">
				<div class="effective-title">
					<p class="c-fs_l">
						<#if damageUpRate?has_content && damageUpRate != 0>
							ダメージ<span class="c-fc_rd">${damageUpRate!?html}%</span>UP中
						<#else>
							<span class="c-fc_rd">有利効果無し</span>
						</#if>
					</p>
				</div>

				<#--- 仲間ボーナス（ステルス）はこの枠内に入れないことに。
				<#if (stealthEffect.effectId)?has_content>
					<section class="c-m15_t c-m10_b">
						<p class="c-m10_t c-m5_b">仲間ボーナス</p>
						<#assign min = "0" + stealthEffect.remainMinutes>
						<#assign sec = "0" + stealthEffect.remainSeconds>
						<p>ダメージ<span class="c-fc_yl ">${(stealthEffect.effectRate - 100)!?html}%UP</span>(<span class="c-fc_rd">あと${min[min?length-2..min?length-2] + min[min?length-1..min?length-1]!?html}:${sec[sec?length-2..sec?length-2] + sec[sec?length-1..sec?length-1]!?html}</span>)</p>
					</section>
					<hr class="raid-border_groove">
				</#if>
				-->

				<#-- 有利カード表示枚数 -->
				<#if activeEffectiveCards?has_content>
					<#assign cardNum = activeEffectiveCards.size()>
				<#else>
					<#assign cardNum = 0>
					<#assign activeEffectiveCards = []>
				</#if>

				<#assign maxEffectiveCards = 10>

				<#-- 最高保持枚数に満たない場合はダミーアイコンを入れる -->
				<#if (cardNum < maxEffectiveCards) >
					<#assign addCards = (maxEffectiveCards - cardNum)>
					<#list 1..addCards as card>
						<#assign activeEffectiveCards = activeEffectiveCards + [{'cardId':0}]>
					</#list>
				</#if>

				<#--
					子使者ボーナス表示領域
				-->
				<#if (childBonus?has_content || childExpBonus?has_content)>
					<section>
						<#if (childBonus == 0) && (childExpBonus == 0)>
							<p class="c-m15_v">子使者を討伐して<br><span class="c-fc_yl">ダメージボーナス&仲間経験値GET!</span></p>
						<#else>
							<p class="c-m15_t c-m5_b">子使者ボーナス</p>
							<div class="c-flex c-flex-pack_center c-m15_b">
								<p class="c-m5_h">ダメージ<span class="c-fc_yl">#{1 + childBonus;m1}倍</span></p>
								<p class="c-m5_h">仲間経験値<span class="c-fc_yl">#{1 + childExpBonus;m1}倍</span></p>
							</div>
						</#if>
					</section>
					<hr class="raid-border_groove">
				</#if>


				<#--
					有利カードボーナス表示領域
				-->
				<section>
					<p class="c-m10_t c-m5_b">有利カード</p>
					<div class="c-flex">
						<#list activeEffectiveCards as card>
							<#-- カード情報が0以外だったらカード、0ならダミー -->
							<#if card.cardId != 0>
								<div class="effective-cards">
									<img src="${statURL!?html}${images.getQuestListCardImageUrl(card.cardId)!?html}" width="50" height="50">
									<img class="icon-rarity" src="${statURL!?html}/img/common/icon/rarity/icon-rarity_type_${card.rarity}.png" width="24" height="24">
								</div>
							<#else>
								<div class="effective-cards cards_dammy">
									<p class="c-fs_xs c-m15_t">未設定</p>
								</div>
							</#if>

							<#-- 5個ずつで改行を挟む -->
							<#if card_index == 4>
								</div>
								<div class="c-flex">
							</#if>
						</#list>
					</div>

					<div class="c-fs_s">
						<p class="c-m10_t">有利効果は<span>${maxEffectiveCards!?html}枚分の合計値</span>が発揮されます。</p>
						<div class="c-align_r c-m5">
							<p><a href="${urlContext!?html}/event/raid/active-effective-card " class="c-text-deco_u c-fc_yl">⇒設定中の有利カード詳細</a></p>
						</div>
					</div>
				</section>

			</div>


			<#--
			##タブ表示
			-->
			<ul class="c-tab c-tab_type_1 c-m20_t">
				<li class="js-tab c-tab__item_type_1 c-flex">
					<a class="c-tab__btn_type_1"><div class="c-tab__text_type_1 c-fc_wh">討伐状況</div></a>
				</li>
				<li class="js-tab c-tab__item_type_1 c-flex">
					<a class="c-tab__btn_type_1"><div class="c-tab__text_type_1 c-fc_wh">討伐メンバー</div></a>
				</li>
			</ul>
			<#--
			##タブ内容
			-->
			<div id="js-renderTabView">
			</div>
			<#--
			##遷移用リスト
			-->
			<ul class="c-list c-list_type_1 c-m30_t">
				<li class="c-list__item">
					<a class="c-list__link c-list-icon c-icon_arrow_type_1 c-fc_wh" href="${urlContext!?html}/character-raid-status">討伐一覧</a>
				</li>
				<li class="c-list__item c-p5_t">
					<a class="c-list__link c-list-icon c-icon_arrow_type_1 c-fc_wh" href="${urlContext!?html}/character-party?assignType=2">討伐パーティ編成</a>
				</li>
				<li class="c-list__item">
					<a class="c-list__link c-list-icon c-icon_arrow_type_1 c-fc_wh" href="${urlContext!?html}/character-list">仲間一覧</a>
				</li>
				<li class="c-list__item">
					<a class="c-list__link c-list-icon c-icon_arrow_type_1 c-fc_wh" href="${urlContext!?html}/event/raid/howto-play">遊び方</a>
				</li>
			</ul>
		</div>
		<#--
		##ダイアログ格納
		-->
		<div id="js-dlgArea" class="loadingHidden" >
			<#--
				###回復ポップアップ
			-->
			<#include "/WEB-INF/content/character/raid/include/bp-recovery-modal.ftl">


			<#---
				###救援依頼詳細選択ポップアップ
			-->
			<section id="js-supportDetailModal">

				<p class="c-m15_t c-m10_b c-fc_yl c-fs_l">救援依頼を出します</p>

				<#-- おまかせで救援 -->
				<p class="c-m15_t">
					<#if (iRaid.rescueStatus == 0) || (iRaid.rescueStatus == 1)>
						<a id="js-supportBtnPerson" class="c-btn c-btn_type_2 c-btn_col_bl_texture c-fs_n ambModalCancel">おまかせで呼ぶ</a>
					<#else>
						<a id="js-supportBtnPerson" class="c-btn c-btn_type_2 c-btn_col_bl_texture c-fs_n ambModalCancel" disabled="disabled">救援済み</a>
					</#if>
				</p>
				<#-- ギルドメンバーに救援 -->
				<p class="c-m15_t">
					<#if (iRaid.rescueStatus == 0 || iRaid.rescueStatus == 2)>
						<a id="js-supportBtnClub" class="c-btn c-btn_type_2 c-btn_col_bl_texture c-fs_n ambModalCancel">ギルドメンバーを呼ぶ</a>
					<#else>
						<a id="js-supportBtnClub" class="c-btn c-btn_type_2 c-btn_col_bl_texture c-fs_n ambModalCancel" disabled="disabled">救援済み</a>
					</#if>
				</p>

				<div class="c-flex c-m15_t c-m10_b">
					<p class="c-btn c-btn_type_1 c-btn_col_gr c-btn_size_xs c-btn_size_h_s ambModalCancel">討伐に戻る</p>
				</div>
				<p class="c-fs_xs c-m10_t">※おまかせはイベントに参加しているユーザーから戦友を優先して50名に依頼を出します</p>

			</section>


			<#--
				###救援依頼完了ポップアップ
			-->
			<section id="js-supportModal">
				<p class="c-p5_v">
					<span class="c-fc_yl">救援依頼を出しました！</span>
				</p>
				<ul id="js-renderSupportView"></ul>
					<p class="c-p10_t"><a class="c-btn c-btn_type_1 c-btn_col_gr c-btn_size_n ambModalCancel">閉じる</a></p>
					<p class="c-p5_v">
					<span id="supportDlgResultMsg" class="c-fc_rd c-state_hidden">戦友を優先して<br>25名に依頼を出しました</span>
				</p>
			</section>
			<#--
				###全力攻撃ポップアップ
			-->
			<section id="js-fullAttackModal">
				<#--
				####ソーマの所持状況によって分岐
				詳細な分岐はftl上部に記載
				全力攻撃時にどれを優先して使うかを判定
				useType 0: 未所持
					1: 通常ソーマ
					2: 自ソーマ
					3: 当日用ソーマ
					4: ハーフソーマ
				-->
				<#if useType != 0>
					<p><span class="c-fc_yl">${useItemName!?html}</span>を使用して<br>全力攻撃しますか？</p>
					<figure class="c-p5_v"><img src="${statURL!?html}${images.getItemImageUrl(useItemId)!?html}" width="60"></figure>
					<p>所持数：<span class="c-fc_yl">${useItemRemainCount!?html}</span></p>
					<div class="c-flex c-p5_v">
						<a id="js-recoveryAttack" class="updateEvt c-btn c-btn_type_1 c-btn_col_gr c-btn_size_s">使用する</a>
					</div>
					<div class="c-flex c-p5_v">
						<a class="ambModalCancel c-btn c-btn_type_1 c-btn_col_gr c-btn_size_s">キャンセル</a>
					</div>
				<#else>
					<p><span class="c-fc_yl">${useItemName!?html}</span>がありません。</p>
					<figure class="c-p5_v"><img src="${statURL!?html}${images.getItemImageUrl(useItemId)!?html}" width="60"></figure>
					<p>所持数：<span class="c-fc_yl">${useItemRemainCount!?html}</span></p>
					<div class="c-flex c-p5_v">
						<a class="c-btn c-btn_type_1 c-btn_col_gr c-btn_size_s" href="${urlContext!?html}/shop">買いに行く</a>
					</div>
					<div class="c-flex c-p5_v">
						<a class="ambModalCancel c-btn c-btn_type_1 c-btn_col_gr c-btn_size_s">キャンセル</a>
					</div>
				</#if>
			</section>
			<#--
				###妙薬攻撃ポップアップ
			-->
			<section id="js-drugAttackModal">
				<#if (raidDrugUserItem.count > 0)>
					<p><span class="c-fc_yl">${raidDrugUserItem.name!?html}</span>を使用します。</p>
					<figure class="c-p5_v"><img src="${statURL!?html}${images.getItemImageUrl(raidDrugUserItem.itemId)!?html}" width="60"></figure>
					<p class="c-fc_yl">所持数：<span class="c-fc_rd">${raidDrugUserItem.count!?html}</span></p>
					<div class="c-flex c-p5_v">
						<a id="js-drugUseAttack" href="${urlContext!?html}/event/raid/boss-animation?raidId=${raidId!?html}&attackType=2" class="updateEvt c-btn c-btn_type_1 c-btn_col_gr c-btn_size_s">使用する</a>
					</div>
					<div class="c-flex c-p5_v">
						<a class="ambModalCancel c-btn c-btn_type_1 c-btn_col_gr c-btn_size_s">キャンセル</a>
					</div>
				<#else>
					<p><span class="c-fc_yl">${raidDrugUserItem.name!?html}</span>がありません。</p>
					<figure class="c-p5_v"><img src="${statURL!?html}${images.getItemImageUrl(raidDrugUserItem.itemId)!?html}" width="60"></figure>
					<p class="c-fc_yl">所持数：<span class="c-fc_rd">${raidDrugUserItem.count!?html}</span></p>
					<div class="c-flex c-p5_v">
						<a class="c-btn c-btn_type_1 c-btn_col_gr c-btn_size_s" href="${urlContext!?html}/shop">買いに行く</a>
					</div>
					<div class="c-flex c-p5_v">
						<a class="ambModalCancel c-btn c-btn_type_1 c-btn_col_gr c-btn_size_s">キャンセル</a>
					</div>
				</#if>
			</section>

			<#--
				### レア子使者討伐報酬モーダル
			-->
			<section id="js-rareBossRewardsModal">
				<div class="rare-boss-header">
					<img class="c-p5_t" src="${statURL!?html}/img/event/raid/boss-detail/rare-rewards-header.png" width="206">
				</div>
				<#-- 討伐者情報 -->
				<#if specialBossSubduedUserRelation?has_content>
					<#assign subduedRelationList = ['', '',  '戦友', 'ギルド', '']>
					<#assign relationColorName = ['', '', 'red', 'green', '']>
					<p class="c-fs_s c-m5_v">
						<span class="text-deco_box_${relationColorName[specialBossSubduedUserRelation]} c-m5_h">${subduedRelationList[specialBossSubduedUserRelation]}</span><span class="c-fc_yl"><@shortName '${specialBossSubuduedUser.name}'/></span>が討伐！
					</p>
				</#if>
				<div class="c-box c-box_type_1 c-box_rounded_5 box-raid-result__mini c-p5_v">
					<p class="c-p5_t">獲得アイテム</p>
					<div class="raid-border raid-border_groove"></div>
					<#if specialBossRewardList?has_content>
						<#list specialBossRewardList as reward>
							<div class="c-flex c-flex-pack_justify c-fs_s">
								<div class="c-flex c-p5_t">
									<figure class="c-p5_h"><img class="" src="${statURL!?html}${reward.imagePath!?html}" width="26px"></figure>
									<#if reward.type == itemType.MONEY.key>
										<p>${reward.typeId!?html}リア</p>
									<#elseif reward.type == itemType.FRIENDSHIP_POINTS.key>
										<p>${reward.typeId!?html}召喚pt</p>
									<#else>
										<p>${reward.name!?html}</p>
									</#if>
								</div>
								<p class="c-p10_r">
									<#if reward.type != itemType.MONEY.key && reward.type != itemType.FRIENDSHIP_POINTS.key>
										×${reward.count!?html}
									</#if>
								</p>
							</div>
						</#list>
					</#if>
				</div>
				<div class="c-flex c-m15_t">
					<a class="js-rewardMdlCloseBtn c-btn c-btn_type_1 c-btn_col_gr c-btn_size_h_s c-btn_size_xxs btn-base-change c-fs_n">閉じる</a>
				</div>
			</section>

			<#--アメーバポイント 完了モジュール-->
			<#if amebaPointResults?has_content && !androidApp && !iphoneApp>
				<#--ブラウザかつポイント取得時のみ表示-->
				<div class="AGP_tools c-m20_t" data-agptype="pointComplete"></div>
			</#if>

		</div><#--end. js-dlgArea-->

		<#--フッタのインクルード-->
		<#include "/WEB-INF/content/common/footer.ftl">
	</div>
	<#--
	* @ js-render
	* 初回デッキ選択情報
	-->
	<script id="js-tmpl_attacBtns" type="text/x-jsrender">
		<#if supportAttackFlg>
			<#--
				###救援時初回消費AP0
			-->
			<div>
				<a class="updateEvt btn-attack btn-attack_free" href="${urlContext!?html}/event/raid/boss-animation?raidId=${raidId!?html}&partyId={{> partyId}}&attackType=0"></a>
			</div>
		<#else>
			<#--
			###通常攻撃
			-->
			<div>
				<#if currentBp != 0 >
					{{if isDisabled}}
						<a class="btn-attack_event btn-attack_normal filter-alpha" disabled=disabled></a>
					{{else}}
						<a class="updateEvt btn-attack_event btn-attack_normal" href="${urlContext!?html}/event/raid/boss-animation?raidId=${raidId!?html}&partyId={{> partyId}}&attackType=0"></a>
					{{/if}}
				<#else>
					<a class="btn-attack_event btn-attack_normal filter-alpha" disabled=disabled></a>
				</#if>
			</div>
			<#--
			###全力攻撃
			-->
			<div class="c-p5_l c-p15_b">
				<p class="c-fs_xs">ダメージ<span class="c-fc_yl">8</span>倍</p>
				<#--BP全快時-->
				{{if isDisabled}}
					<a class="btn-attack_event btn-attack_full filter-alpha" disabled=disabled></a>
				{{else}}
					<#if fullyRecoverd>
						<a class="updateEvt btn-attack_event btn-attack_full" href="${urlContext!?html}/event/raid/boss-animation?raidId=${raidId!?html}&partyId={{> partyId}}&attackType=1"></a>
					<#else>
						<a id="js-fullAttackBtn" class="btn-attack_event btn-attack_full"></a>
					</#if>
				{{/if}}
			</div>
			<#---
			###妙薬攻撃
			-->
			<div class="c-p15_b">
				<p class="c-fs_xs">ダメージ<span class="c-fc_yl">16</span>倍</p>
				{{if isDisabled}}
					<a class="btn-attack_event btn-attack_drug filter-alpha" disabled=disabled></a>
				{{else}}
					<a id="js-drugAttackBtn" class="btn-attack_event btn-attack_drug"></a>
				{{/if}}
			</div>
		</#if>
	</script>
	<#--
	* @ js-render
	* 初回デッキ選択情報
	-->
	<script id="js-tmpl_partyInfo" type="text/x-jsrender">
		<div class="modal-boss-top">
			<div class="c-box c-box_type_6 c-box_rounded_5 c-m10_h c-m20_b c-p5_b modal-boss-top__inner">
				<h2 class="c-p5_t">討伐パーティ確認</h2>
				<div class="c-flex c-flex-pack_justify c-p10_h c-p5_t">
					<div id="js-changePartyBtn" class="c-m5_r c-m5_t icon-party icon-party_type_{{> partyIndex}}"></div>
					{{for characterList}}
					<figure class="chara-thumb">
						{{if raceId}}
						<i class="chara-thumb__icon-race c-icon-race c-icon-race_size_s c-icon-race_type_{{> raceId}}"></i>
						{{/if}}
						<img src="{{> src}}" width="44" height="44" />
					</figure>
					{{/for}}
					<figure class=""><img src="${statURL!?html}/img/character/icon-race-hint.png" width="44"></figure>
				</div>
				<p class="c-p5_t">初回のみパーティ変更が可能です</p>
				{{if isAttackPossible == false}}
					<p class="c-p5_v c-fc_rd">未設定デッキがあるため攻撃できません</p>
				{{/if}}
				<div class="c-align_r c-p5_t c-p10_b c-p10_r btn-on-list">
					<p><a href="${urlContext!?html}/character-party?assignType=2" class="c-text-deco_u">⇒パーティを編成</a></p>
				</div>
				<div class="js-closeModalBtn modal-boss-top__close"></div>
			</div>
		</div><#--end .modal-boss-top-->
	</script>
	<#--
	* @ js-render
	* 討伐状況
	-->
	<script id="js-tmpl_attackStatus" type="text/x-jsrender">
		<h1 class="c-hd c-hd_type_3 c-hd_col_rd">討伐状況</h1>
		<#--遭遇ゲージ-->
		<#include "/WEB-INF/content/event/raid/include/raid-boss-encount.ftl">

		<#-- 常時レイドは一旦コメントアウト
			<#include "/WEB-INF/content/character/raid/include/character-raid-boss-encount.ftl">
		-->
	</script>
	<#--
	* @ js-render
	* 討伐メンバー
	-->
	<script id="js-tmpl_attackMenbers" type="text/x-jsrender">
		<h1 class="c-hd c-hd_type_4 c-hd_col_rd">討伐メンバー</h1>
		<ul class="c-listview c-listview_type_3">
			<#if (memberInfos?size <= 0)>
				<p class="c-p20_v">討伐メンバーはいません</p>
			<#else>
				<#list memberInfos as member>
					<#assign memberAvaterImageUrl = "${statURL!?html}${images.getAvatarImageUrl(member.avatarId)!?html}">
					<#assign memberLeaderCardImageUrl = "${statURL!?html}${images.getQuestListCardImageUrl(member.leaderCardId)!?html}">
					<li class="c-listview__item">
						<h1 class="c-hd c-hd_type_5">
							<#if member.findFlg>
								<p><span class="c-fc_yl">発見者：</span>${member.name!?html}</p>
							<#else>
								<p><span class="c-fc_yl">討伐メンバー：</span>${member.name!?html}</p>
							</#if>
						</h1>
						<a class="c-list__link c-p5" href="${urlContext!?html}/profile?userId=${member.userId!?html}">
							<div class="c-flex c-flex-pack_start">
								<div class="c-flex">
									<img class="" src="${memberAvaterImageUrl!?html}" width="56px">
									<img class="" src="${memberLeaderCardImageUrl!?html}" width="56px">
								</div>
								<ul class="c-p10 c-align_l">
									<li>
										<p><span class="c-fc_yl">攻撃回数：</span>${member.attackCount!?html}</p>
										<p class="c-fc_yl">ダメージ：</p>
										<p>${member.damage!?html}</p>
									</li>
								</ul>
							</div>
						</a><#--end .c-list__link-->
					</li><#--end .c-listview__item-->
				</#list>
			</#if>
		</ul>
		<hr>
	</script>

	<#--　
	救援依頼送信先 @jsRender　
	-->
	<script id="js-tmpl_supportList" type="text/x-jsrender">
		{{if relation != null && relation != 0}}
			<li class="c-p5_t">
				{{if relation==2}}<span class="text-deco_box_red">戦友</span>{{/if}}
				{{if relation==3}}<span class="text-deco_box_green">ギルド</span>{{/if}}
				{{if relation==4}}{{/if}}
				{{> userName}}
			</li>
		{{/if}}
	</script>

	<#--JavaScriptのインポート 後で評価する方が高速なので、ここに書く-->
	<#include "/WEB-INF/content/common/htmlFoot.ftl">
	<script>
		$(function() {
			var mgc = window.jp.ameba.mgc_s,
			attackStatuses = [];

			/**
			 * 各パーティが攻撃可能かどうかをチェック
			 **/

			<#list partyIds as currentId>
				attackStatuses.push(true);
			</#list>
			<#list partyIds as currentId>
				<#list partyCharacterListMap.get(currentId) as chara>
					<#if (chara.rating <= 0)>
						attackStatuses[${currentId_index}] = false;
					</#if>
				</#list>
			</#list>

			mgc.data = {
				raidId: "${raidId!?html}",
				//初撃判定
				<#if firstFlg>
					isFirstAttack: true,
					partyId: null,
				<#else>
					isFirstAttack: false,
					partyId: "${partyId!?html}",
				</#if>
				// この画面に初めて訪れたかどうか
				isFirstOpen: <#if firstOpen>true<#else>false</#if>,
				// レア使者が倒されたかどうか
				hasRareChildBossRewards: <#if specialBossRewardList?has_content>true<#else>false</#if>,
				// レア子使者がいるかどうか
				hasRareChildBoss: <#if hasRareChildBoss>true<#else>false</#if>,
				// ティッカーを表示するかどうか
				hasTickerInfo: <#if result?has_content>true<#else>false</#if>,
				//コマンドウインドウでのガイドメッセージ
				guideMessage: {
					READY: '仲間をタップしてください',
					CHARACTER: '攻撃する使者を選択してください',
					ENEMY: '仲間をタップしてください',
					AUTO: '<span class="c-fc_rd">おすすめターゲットにしているため変更できません</span>'
				},
				//プリロード画像用配列
				manifest: [
					<#list childBossInfos as childboss>
						<#if childboss.MRaidBoss.additionalType == 1>
							{id: 'js-bossParts${childboss_index + 1}', src: '${statURL!?html}/img/event/raid/boss/105x105_battle/rare-boss_${isRareChildStatus!?html}.png', width: 90},
						<#else>
							{id: 'js-bossParts${childboss_index + 1}', src: '${statURL!?html}/img/event/raid/${eventId!?html}/boss/105x105_battle/boss_${childboss.MRaidBossDetail.bossDetailId!?html}.png', width: 90},
						</#if>
					</#list>
					{id: 'js-bossImage', src: '${statURL!?html}/img/event/raid/${eventId!?html}/boss/640x508_detaile/boss_${parentBossDetail.bossDetailId!?html}.png', width: 320},
					{id: 'js-bossBgImage', src: '${statURL!?html}/img/event/raid/${eventId!?html}/bg2_${bossBgType!?html}.jpg', width: 320}
				],
				//パーティのアイコン画像
				charaImages: [
					<#list partyIds as partyId>
						'<i class="icon-character icon-character_type_${partyId_index}"></i>'
						<#if (partyId_index + 1) != partyIds?size>,</#if>
					</#list>
				],
				//使者情報
				enemies: [
					{
						maxHp: ${parentBossInfo.maxHitPoints!?html},
						currentHp: ${parentBossInfo.currentHitPoints!?html},
						raceId: ${parentBoss.raceId!?html}
					},
					<#list childBossInfos as childboss>
						<#assign childInfo = childboss.MRaidBoss>

						<#-- レアボスが逃亡後だったらHPを0に設定 -->
						<#if childboss.escapeDatetime?has_content>
							<#assign currenHitPointsClone = 0>
						<#else>
							<#assign currenHitPointsClone = childboss.currentHitPoints>
						</#if>

						{
							maxHp: ${childboss.maxHitPoints!?html},
							currentHp: ${currenHitPointsClone!?html},
							raceId: ${childInfo.raceId!?html}
						}
						<#if (childboss_index + 1) != childBossInfos?size>,</#if>
					</#list>
				],
				//パーティ情報
				partyList: [
					<#list partyIds as currentId>
						{
							userId: null, //jsで設定
							partyIndex: null,//jsで設定
							partyType: null,//jsで設定
							partyId: "${currentId!?html}",
							characterList: [
								<#assign charaList = partyCharacterListMap.get(currentId)>
								<#list partyCharacterListMap.get(currentId) as chara>
									{
										rating: ${chara.rating!?html},

										<#-- それぞれの属性に攻撃した際の攻撃力（'-', 天, 地, 冥） -->
										<#assign ratingArray =  supposedDeckDamage.get(currentId)>
										<#assign test = ratingArray[chara_index]>
										afterRating: ['', ${test.get('1')}, ${test.get('2')}, ${test.get('3')}],

										<#if chara_index == 0>
											src: '${statURL!?html}/img/avatar/icon/avatar_${iUser.sphereId!?html}_${iUser.sex!?html}.png'
										<#elseif chara.characterInfo?has_content>
											src: '${statURL!?html}${images.getCharacterType01ImageUrl(chara.characterInfo.characterMaster.id)!?html}',
											raceId: ${chara.characterInfo.characterMaster.raceId!?html}
										<#else>
											src: '${statURL!?html}/img/character/thumb-empty.png'
										</#if>
									}
									<#if (chara_index + 1) != charaList?size>,</#if>
								</#list>
							],
							isAttackPossible: attackStatuses[${currentId_index}]
						}
						<#if (currentId_index + 1) != partyIds?size>,</#if>
					</#list>
				],
				//ターゲット情報
				targetOrder: [
				<#list targetInfos as target>
					{
						chara: ${target.characterOder!?html},
						enemy: ${target.bossOrder!?html}
					}
					<#if (target_index + 1) != targetInfos?size>,</#if>
				</#list>
				],
				// 初期値となるターゲット情報
				firstTargetOrder: [
					<#if useRecommendBossTarget>
						<#list recommendBossTarget.get(partyId) as target>
							{
								chara: ${target.characterOder!?html},
								enemy: ${target.bossOrder!?html}
							}
							<#if (target_index + 1) != targetInfos?size>,</#if>
						</#list>
					<#else>
						<#list targetInfos as target>
							{
								chara: ${target.characterOder!?html},
								enemy: ${target.bossOrder!?html}
							}
							<#if (target_index + 1) != targetInfos?size>,</#if>
						</#list>
					</#if>
				],
				// おすすめターゲット情報
				isRecomendTarget: <#if useRecommendBossTarget>true<#else>false</#if>,
				recomendTargetOrder: [
				<#list recommendBossTarget.get(partyId) as target>
					{
						chara: ${target.characterOder!?html},
						enemy: ${target.bossOrder!?html}
					}
					<#if (target_index + 1) != targetInfos?size>,</#if>
				</#list>
				],
				//アイテム使用攻撃URL
				recoveryAttackUrl: "${urlContext!?html}/event/raid/boss-animation?raidId=${raidId!?html}&attackType=1&useItemId=${useItemId!?html}",
				//妙薬攻撃URL
				drugUseAttackUrl: "${urlContext!?html}/event/raid/boss-animation?raidId=${raidId!?html}&attackType=2",
				// アイテムポップアップ用
				regenItemData: [
					// 英気のソーマ
					{
						id: ${powerRegenItem.itemId!?html},
						name: "${powerRegenItem.name!?html}",
						src: "${statURL!?html}${images.getItemImageUrl(powerRegenItem.itemId)!?html}",
						count: ${powerRegenItemCount},
						description: '全回復する',
						priority: 3,
						recovery: 6,
						disabled: false
					},
					// ソーマ(自分用)
					{
						id: ${powerRegenMyselfItem.itemId!?html},
						name: "ソーマ(自)<#--${powerRegenMyselfItem.name!?html}-->",
						src: "${statURL!?html}${images.getItemImageUrl(powerRegenMyselfItem.itemId)!?html}",
						count: ${powerRegenMyselfItemCount},
						description: '全回復する',
						priority: 2,
						recovery: 6,
						disabled: false
					},
					// ソーマ(当日用)
					{
						id: ${powerRegenOneDayItem.itemId!?html},
						name: "ソーマ(当日)<#--${powerRegenOneDayItem.name!?html}-->",
						src: "${statURL!?html}${images.getItemImageUrl(powerRegenOneDayItem.itemId)!?html}",
						count: ${powerRegenOneDayItemCount},
						description: '全回復する',
						priority: 1,
						recovery: 6,
						disabled: false
					}
				],
				regenHalfItemData: [
					// ソーマハーフ
					{
						id: ${powerRegenMyselfHalfItem.itemId!?html},
						name: "ソーマハーフ<#--${powerRegenMyselfHalfItem.name!?html}-->",
						src: "${statURL!?html}${images.getItemImageUrl(powerRegenMyselfHalfItem.itemId)!?html}",
						count: ${powerRegenMyselfHalfItemCount},
						description: '3回復する',
						priority: 1,
						recovery: 3,
						disabled: false
					}
				],
				regenDropData: [
					// ドロップ
					{
						id: ${apRegenItem.itemId!?html},
						name: "英力のドロップ<#---->",
						count: ${apRegenItemCount!?html},
						src: "${statURL!?html}${images.getItemImageUrl(apRegenItem.itemId)!?html}",
						description: '1回復する',
						priority: 2,
						recovery: 1,
						disabled: false
					},
					// ドロップ（当日用）
					{
						id: ${apRegenOneDayItem.itemId!?html},
						name: "英力のドロップ(当日)<#---->",
						count: ${apRegenOneDayItemCount!?html},
						src: "${statURL!?html}${images.getItemImageUrl(apRegenOneDayItem.itemId)!?html}",
						description: '1回復する',
						priority: 1,
						recovery: 1,
						disabled: false
					}
				],
				//現在のBP
				battlePower: ${currentBp},
				//最大BP
				maxBattlePower: ${maxBp},
				//回復処理用URL
				submitURL: "${urlContext!?html}/battle/battle-power-regen?",
				//token
				token: "${token!?html}",
				//BP画像
				bpImg: {
					src: "${statURL!?html}/img/character/raid/icon-bp.png"
				},
				//BP画像(空)
				bpEmptyImg: {
					src: "${statURL!?html}/img/character/raid/icon-bp_empty.png"
				}
			};
			mgc.page = new mgc.controllers.RaidBossDetailController();
		});
	</script>

	<#include "/WEB-INF/content/common/pc-footer-content.ftl">
</body>
</html>
</#compress>
