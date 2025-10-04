(deffunction member (?item $?list)
   (if (lexemep ?item) ; Проверяем, является ли элемент строкой
      then (bind ?item (lowcase ?item))) ; Если да, приводим к нижнему регистру
   (member$ ?item ?list)) ; Проверяем наличие элемента в списке

(deffunction ask-question (?question $?allowed-values)
   (printout t ?question) ; Выводим вопрос на экран
   (bind ?answer (read)) ; Читаем ответ пользователя
   (if (lexemep ?answer) ; Если ответ - строка
      then (bind ?answer (lowcase ?answer))) ; Приводим к нижнему регистру
   (while (not (member ?answer ?allowed-values)) do ; Пока ответ недопустим
      (printout t ?question) ; Повторяем вопрос
      (bind ?answer (read)); Снова читаем ответ
      (if (lexemep ?answer); Если снова строка
         then (bind ?answer (lowcase ?answer)))) ; Приводим к нижнему регистру
   ?answer) ; Возвращаем валидный ответ

(deffunction YesOrNo (?question)
   (bind ?response (ask-question ?question да нет)) ; Задаем вопрос с вариантами
   (if (eq ?response да) ; Если ответ "да"
      then TRUE  ; Возвращаем TRUE
      else FALSE)) ; Иначе FALSE

(defrule print
   (declare (salience 0)) ; Низкий приоритет выполнения
   (repair ?item) =>  ; Если есть факт repair
   (printout t crlf)  ; Переход на новую строку
   (format t "%s%n%n%n" ?item)) ; Форматированный вывод сообщения

; 0  
(defrule zero-question ""
(not (health?)) ; Если здоровье не проверялось
(not (repair?)) ; И нет предыдущих ограничений
 =>
(if (YesOrNo "Есть ли у ребенка хронические заболевания/противопоказания? Напишите да/нет: ")
then 
(assert (health right))
else
(assert (health no))))

; + 
(defrule musculoskeletal ""
(health right)
(not (musculoskeletal?))
(not (repair?)) =>
(if (YesOrNo "Есть ли проблемы с опорно-двигательным аппаратом? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемые секции: Плавание или ЛФК."))
else
(assert (musculoskeletal no))))


; +- 
(defrule breath ""
(musculoskeletal no)
(not (breath?))
(not (repair?)) =>
(if (YesOrNo "Есть ли дыхательные проблемы (пр. астма)? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемая секция: Йога."))
else
(assert (breath no))))


; +-- 
(defrule activeact ""
(breath no)
(not (activeact?))
(not (repair?)) =>
(if (YesOrNo "Есть ли противопоказания по активной деятельности? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемые секции: Стретчинг, пилатес."))
else
(assert (repair "Рекомендуемая секция: Аквааэробика."))))



; -
(defrule ageless3 ""
(health no)
(not (ageless3?))
(not (repair?)) =>
(if (YesOrNo "Ребенку меньше 3-х лет? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемые секции: Игровые развивающие секции."))
else
(assert (ageless3 no))))

; -- 
(defrule agemore7 ""
(ageless3 no)
(not (agemore7?))
(not (repair?)) =>
(if (YesOrNo "Ребенку больше 7-и лет? Напишите да/нет: ")
then 
(assert (agemore7 right))
else
(assert (agemore7 no))))

; --+ 
(defrule teamgames7 ""
(agemore7 right)
(not (teamgames7?))
(not (repair?)) =>
(if (YesOrNo "Есть ли интерес к командным играм? Напишите да/нет: ")
then 
(assert (teamgames7 right))
else
(assert (teamgames7 no))))

; --++ 
(defrule hight ""
(teamgames7 right)
(not (hight?))
(not (repair?)) =>
(if (YesOrNo "Есть ли генетически заложенный высокий рост? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемые секции: Волейбол, баскетбол."))
else
(assert (repair "Рекомендуемые секции: Футбол, регби."))))

; --+- 
(defrule fight ""
(teamgames7 no)
(not (fight?))
(not (repair?)) =>
(if (YesOrNo "Интересуют ли боевые искусства? Напишите да/нет: ")
then 
(assert (fight right))
else
(assert (fight no))))

; --+-+ 
(defrule traditionalfight ""
(fight right)
(not (traditionalfight?))
(not (repair?)) =>
(if (YesOrNo "Интересуют ли традиционные/философские стили? Напишите да/нет: ")
then 
(assert (traditionalfight right))
else
(assert (traditionalfight no))))

; --+-++ 
(defrule weapon ""
(traditionalfight right)
(not (weapon?))
(not (repair?)) =>
(if (YesOrNo "Хочет ли ребенок работать с оружием? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемые секции: Кэндо, кобудо, ушу."))
else
(assert (repair "Рекомендуемая секция: Айкидо."))))

; --+-+- 
(defrule career ""
(traditionalfight no)
(not (career?))
(not (repair?)) =>
(if (YesOrNo "Готов ли ребенок посвятить себя карьере в олимпийском виде спорта? Напишите да/нет: ")
then 
(assert (career right))
else
(assert (repair "Рекомендуемые секции: Муай-тай, джиу-джитсу."))))

; --+-+-+ 
(defrule flexibility ""
(career right)
(not (flexibility?))
(not (repair?)) =>
(if (YesOrNo "Гибкий ли ребенок? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемые секции: Тхэквондо, карате."))
else
(assert (repair "Рекомендуемые секции: Дзюдо, бокс, кикбоксинг."))))



; --+-- 
(defrule logic ""
(fight no)
(not (logic?))
(not (repair?)) =>
(if (YesOrNo "Любит ли анализировать и просчситывать ходы? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемые секции: Шахматы, го."))
else
(assert (logic no))))

; --+--- 
(defrule strong ""
(logic no)
(not (strong?))
(not (repair?)) =>
(if (YesOrNo "Физически развитый ли ребенок? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемые секции: Тяжелая атлетика, гиревой спорт, пауэрлифтинг."))
else
(assert (strong no))))

; --+---- 
(defrule feelbody ""
(strong no)
(not (feelbody?))
(not (repair?)) =>
(if (YesOrNo "Хорошо ли у ребенка развита телесная координация? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемые секции: Танцы, фехтование."))
else
(assert (repair "Рекомендуемые секции: Стрельба из лука, метание."))))



; --- 
(defrule activechild ""
(agemore7 no)
(not (activechild?))
(not (repair?)) =>
(if (YesOrNo "Активный ли ребенок? Напишите да/нет: ")
then 
(assert (activechild right))
else
(assert (activechild no))))

; ---- 
(defrule hourse ""
(activechild no)
(not (hourse?))
(not (repair?)) =>
(if (YesOrNo "Любит ли лошадей? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемая секция: Конный спорт."))
else
(assert (hourse no))))

; ----- 
(defrule water ""
(hourse no)
(not (water?))
(not (repair?)) =>
(if (YesOrNo "Любит ли плавать? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемая секция: Плавание."))
else
(assert (repair "Рекомендуемые секции: Керлинг, гольф, мини-теннис."))))


; ---+ 
(defrule run ""
(activechild right)
(not (run?))
(not (repair?)) =>
(if (YesOrNo "Любит ли бегать? Напишите да/нет: ")
then 
(assert (run right))
else
(assert (run no))))

; ---++ 
(defrule communication ""
(run right)
(not (communication?))
(not (repair?)) =>
(if (YesOrNo "Хорошо ли находит язык с другими детьми? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемая секция: Футбол."))
else
(assert (repair "Рекомендуемая секция: Легкая атлетика."))))

; ---+- 
(defrule naturalflexibility ""
(run no)
(not (naturalflexibility?))
(not (repair?)) =>
(if (YesOrNo "Есть ли природная гибкость, растяжка? Напишите да/нет: ")
then 
(assert (naturalflexibility right))
else
(assert (naturalflexibility no))))

; ---+-+ 
(defrule slim ""
(naturalflexibility right)
(not (slim?))
(not (repair?)) =>
(if (YesOrNo "Худощавое ли телосложение? Напишите да/нет: ")
then 
(assert (slim right))
else
(assert (slim no))))

; ---+-+-
(defrule physpower ""
(slim no)
(not (physpower?))
(not (repair?)) =>
(if (YesOrNo "Физически развитый ли ребенок? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемые секции: Акробатика, спортивная гимнастика."))
else
(assert (repair "Рекомендуемая секция: Фехтование."))))

; ---+-++
(defrule swim ""
(slim right)
(not (swim?))
(not (repair?)) =>
(if (YesOrNo "Любит ли ребенок плавать? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемая секция: Синхронное плавание."))
else
(assert (swim no))))

; ---+-++-
(defrule winter ""
(swim no)
(not (winter?))
(not (repair?)) =>
(if (YesOrNo "Интересуется ли зимними видами спорта? Или катается на коньках? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемая секция: Фигурное катание."))
else
(assert (repair "Рекомендуемые секции: Балет, художественная гимнастика."))))



; ---+-- 
(defrule rythm ""
(naturalflexibility no)
(not (rythm?))
(not (repair?)) =>
(if (YesOrNo "Есть ли чувство ритма? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемые секции: Бальные танцы, танцы."))
else
(assert (rythm no))))

; ---+--- 
(defrule barriers ""
(rythm no)
(not (barriers?))
(not (repair?)) =>
(if (YesOrNo "Любит ли находить способы обойти/перелезть через преграды? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемая секция: Скалолазанье."))
else
(assert (barriers no))))

; ---+---- 
(defrule react ""
(barriers no)
(not (react?))
(not (repair?)) =>
(if (YesOrNo "Хорошая ли природная реакция? Напишите да/нет: ")
then 
(assert (react right))
else
(assert (repair "Рекомендуемая секция: Дзюдо."))))

; ---+----+ 
(defrule comgames ""
(react right)
(not (comgames?))
(not (repair?)) =>
(if (YesOrNo "Любит ли командные игры? Напишите да/нет: ")
then 
(assert (repair "Рекомендуемая секция: Хоккей."))
else
(assert (repair "Рекомендуемая секция: Большой теннис."))))