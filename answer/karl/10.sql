-- 在LOL角色中，有些角色會比較容易打贏或打輸特定角色。列出當上路 (TOP) 對手為雷尼克頓 (Renekton) 時，上路 (TOP) 角色勝率（參考第九題定義）最高的前五隻英雄，並列出上路 (TOP) 雙方的總擊殺參與率 (總KDA，參考第七題定義) 與平均經濟 (goldearned)。這邊我們只在乎與雷尼克頓 (Renekton) 對峙的資料大於100筆的英雄

select filt.self_champ_name, (filt.sum_win/filt.cnt) as win_ratio, filt.self_kda, 
    filt.self_avg_gold, filt.enemy_champ_name, filt.enemy_kda, filt.enemy_avg_gold, filt.cnt as battle_record
from 
(
    select un2.self_champ_name, count(un2.self_champ_name) as cnt, 
        sum(un2.self_win) as sum_win, 
        (sum(un2.self_kills)+sum(un2.self_assists))/sum(un2.self_deaths) as self_kda,
        avg(un2.self_gold) as self_avg_gold, un2.enemy_champ_name, 
        (sum(sub_stat2.kills)+sum(sub_stat2.assists))/sum(sub_stat2.deaths) as enemy_kda, 
        avg(sub_stat2.goldearned) as enemy_avg_gold
    from
    (
        select un1.self_champ_name, sub_stat.win as self_win,
        sub_stat.kills as self_kills, sub_stat.deaths as self_deaths, 
        sub_stat.assists as self_assists, sub_stat.goldearned as self_gold, 
        un1.enemy_player_id, un1.enemy_champ_name
        from
        (
            select p1.player_id as self_player_id, p1.champion_name as self_champ_name,
                p2.player_id as enemy_player_id, p2.champion_name as enemy_champ_name 
            from
            (
                select par.player_id, par.match_id, champ.champion_name
                from participant as par, champ
                where par.player < 6
                and par.position = 'TOP'
                and champ.champion_id = par.champion_id
            ) as p1,
            (
                select par.player_id, par.match_id, champ.champion_name
                from participant as par, champ
                where par.player > 5
                and par.position = 'TOP'
                and champ.champion_id = par.champion_id
            ) as p2
            where p1.match_id = p2.match_id
            and p2.champion_name = 'Renekton'
            union
            select p2.player_id as self_player_id, p2.champion_name as self_champ_name,
                p1.player_id as enemy_player_id, p1.champion_name as enemy_champ_name 
            from
            (
                select par.player_id, par.match_id, champ.champion_name
                from participant as par, champ
                where par.player < 6
                and par.position = 'TOP'
                and champ.champion_id = par.champion_id
            ) as p1,
            (
                select par.player_id, par.match_id, champ.champion_name
                from participant as par, champ
                where par.player > 5
                and par.position = 'TOP'
                and champ.champion_id = par.champion_id
            ) as p2
            where p1.match_id = p2.match_id
            and p1.champion_name = 'Renekton'
        ) as un1, 
        (
            select player_id, win, kills, deaths, assists, goldearned
            from stat
        ) as sub_stat
        where un1.self_player_id = sub_stat.player_id
    ) as un2,
    (
        select player_id, win, kills, deaths, assists, goldearned
        from stat
    ) as sub_stat2
    where un2.enemy_player_id = sub_stat2.player_id
    group by un2.self_champ_name, un2.enemy_champ_name
) as filt
where filt.cnt > 100
order by win_ratio desc
limit 5;