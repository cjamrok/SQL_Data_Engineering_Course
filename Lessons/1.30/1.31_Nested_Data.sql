--this gets really complicated further down with MAPs and JSON and what not. 
--I think the takeaway is that whatever list/array data you acquire, your goal
--should be to convert it to an array of structs using SQL. This is the most "queryable"
--array data and most commonly used. You shouldn't query JSON data directly for example, 
--you should convert it to array of structs first and then query that instead. 

SELECT [1,2,3];

SELECT ['python','sql','R'] AS "skills_array";

--use a function to build an array
--always define order by with an aggregate/array function!!!!!
WITH CTE AS (
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'R')
SELECT ARRAY_AGG(skill) FROM CTE;

--with an Index
WITH CTE AS (
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'r'),
List_Array AS (SELECT ARRAY_AGG(skill ORDER BY skill) AS skills FROM CTE) --Order by makes sure the 
SELECT
skills[1] AS first_skill,
skills[2] AS second_skill,
skills[3] AS third_skill,
FROM List_Array
;
-- I don't understand why I have a different array order than Luke does. His was alphabetical and mine isnt...
-- lol I guess case sensitivity even impacts order bys in SQL. when I lowercased "R" to "r" it fixed it.

--Struct Intro
SELECT { skill: 'python', type: 'programming'} AS skill_struct;

--use a function to build a Struct
SELECT
    STRUCT_PACK(
        skill := 'python',
        type := 'programming'
    ) AS my_struct;

--with CTE
WITH CTE AS (
SELECT
    STRUCT_PACK(
        skill := 'python',
        type := 'programming'
    ) AS my_struct
) 
SELECT --unpack by specifying columns rather than running wide open *
    my_struct.skill,
    my_struct.type
FROM CTE;

WITH CTE AS (
SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
)
SELECT 
    STRUCT_PACK(
        skill := skills,
        type := types
    ) FROM CTE;


--woof...array of structs. Feel like I'm in Inception right now

SELECT [
    {skill: 'python', type: 'programming'},
    {skills: 'sql', type: 'query_language'}
] AS skills_array_of_structs;

--one row, an array [] of structs {} = [{},{}]
WITH CTE AS (
SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
)
SELECT 
    ARRAY_AGG(
        STRUCT_PACK(
            skill := skills,
            type := types
        )
    ) 
FROM CTE;

--how do you access items within an array/struct? 
WITH CTE AS (
SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
), skills_array_struct AS (
SELECT 
    ARRAY_AGG(
        STRUCT_PACK(
            skill := skills,
            type := types
        )
    ) AS array_struct
FROM CTE
)
--select individual columns rather than * for queryt to return individual fields rather than entire struct
SELECT array_struct[1].skill,
array_struct[2].type,
array_struct[3] FROM skills_array_struct
;

--MAP / Object / Dictionary
--not as popular as arrays or arrays of structs
--I'm skipping this, it shows up in at 12:10:00 on the youtube video

--JSON
--You won't be building pipelines with JSON, you'll be receiving JSON that needs to be
--parsed out and cleaned up

SELECT 
    TO_JSON('{"skill":"python", "type":"programming"}') AS skill_json;
    --contains escape acharacters annoyingly

--use CAST instead
WITH JSON_CTE AS (
SELECT 
    '{"skill":"python", "type":"programming"}'::JSON AS skill_json
)
SELECT
    STRUCT_PACK(
        skills := json_extract_string(skill_json, '$.skill'),
        types := json_extract_string(skill_json, '$.type')
    )
skill_json FROM JSON_CTE;

-- JSON to array of structs --pulled straight from Luke's query, didn't fully understnad this yet
WITH raw_json AS (
    SELECT
        '[
            {"skill":"python","type":"programming"},
            {"skill":"sql","type":"query_language"},
            {"skill":"r","type":"programming"}
        ]'::JSON AS skills_json
)
SELECT
        ARRAY_AGG(
            STRUCT_PACK(
                skill := json_extract_string(e.value, '$.skill'),
                type  := json_extract_string(e.value, '$.type')
            )
            ORDER BY json_extract_string(e.value, '$.skill')
    ) AS skills
FROM raw_json,
     json_each(skills_json) AS e;

