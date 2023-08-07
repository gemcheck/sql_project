PGDMP         %                {         
   car_rental    15.1    15.1 (    ,
           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            -
           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            .
           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            /
           1262    25065 
   car_rental    DATABASE     ~   CREATE DATABASE car_rental WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';
    DROP DATABASE car_rental;
                postgres    false            о            1255    25269 '   add_real_return(integer, date, integer) 	   PROCEDURE     T  CREATE PROCEDURE public.add_real_return(IN id integer, IN return_date date, IN fine integer)
    LANGUAGE plpgsql
    AS $$
declare
	pen integer:=0;
	data_del date;
	in_day integer;
BEGIN
	in_day:= (select c.cost / 250 from cars as c, issued_cars as ic where ic.id_car = c.id_car and id = id_issued);
	data_del:= (select data_delivery from issued_cars where id_issued = id);
	if EXTRACT(DAY FROM Age(return_date,data_del))+1 > 0 then
	pen = (EXTRACT(DAY FROM Age(return_date,data_del))) * 2 * in_day; end if;
	pen = pen + fine;
    INSERT INTO real_refunds VALUES(id, return_date, pen);
END; $$;
 \   DROP PROCEDURE public.add_real_return(IN id integer, IN return_date date, IN fine integer);
       public          postgres    false            п            1255    25861 4   calculate_rental_price(integer, integer, date, date) 	   PROCEDURE     J  CREATE PROCEDURE public.calculate_rental_price(IN in_id_car integer, IN in_id_client integer, IN in_rental_start date, IN in_rental_end date)
    LANGUAGE plpgsql
    AS $$
DECLARE
in_day INTEGER;
days INTEGER;
pen INTEGER;
arenda INTEGER;
req SMALLINT;
on_problems SMALLINT;
discount INTEGER := 0;
id_is SMALLINT;
stat SMALLINT;
BEGIN
  stat := (SELECT status FROM cars WHERE id_car = in_id_car);
  IF stat = 1 THEN
in_day:= (SELECT cost / 250 FROM cars WHERE id_car = in_id_car);
days:= EXTRACT(DAY FROM Age(in_rental_end,in_rental_start))+1;
pen:= (SELECT debt FROM client_refunds WHERE id_client = in_id_client);
req:= (SELECT requests FROM client_refunds WHERE id_client = in_id_client);
on_problems:= (SELECT on_time - problems FROM client_refunds WHERE id_client = in_id_client);
IF req > 5 and on_problems > 3 THEN discount = (in_day * days + pen)/10;
ELSIF req > 3 and on_problems > 2 THEN discount = (in_day * days + pen)/20;
END IF;
id_is:=(SELECT id_issued+1 FROM issued_cars ORDER BY id_issued DESC LIMIT 1);
arenda = in_day * days + pen - discount;
INSERT INTO issued_cars VALUES (id_is, in_id_car, in_id_client, in_rental_start, in_rental_end, arenda);
UPDATE client_refunds SET debt = 0 WHERE in_id_client = id_client;
  ELSE RAISE EXCEPTION 'Р”Р°РЅРЅС‹Р№ Р°РІС‚РѕРјРѕР±РёР»СЊ СѓР¶Рµ РЅР°С…РѕРґРёС‚СЃСЏ РІ Р°СЂРµРЅРґРµ!'; END IF;
END;$$;
 Ќ   DROP PROCEDURE public.calculate_rental_price(IN in_id_car integer, IN in_id_client integer, IN in_rental_start date, IN in_rental_end date);
       public          postgres    false            а            1255    25274    get_car_models_by_year(integer)    FUNCTION     #  CREATE FUNCTION public.get_car_models_by_year(year_param integer) RETURNS TABLE(make character, model character)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT cars.brand, cars.model
                 FROM cars
                 WHERE year >= year_param and status = 1;
END;
$$;
 A   DROP FUNCTION public.get_car_models_by_year(year_param integer);
       public          postgres    false            Э            1255    25190    update_debt_in_returns()    FUNCTION     „  CREATE FUNCTION public.update_debt_in_returns() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	issued int;
BEGIN
	issued:= (select cr.id_client from client_refunds as cr, issued_cars as ic
	WHERE cr.id_client = ic.id_client 
	and ic.id_issued = NEW.id_issued) ;
	
    UPDATE client_refunds
    SET debt = debt + NEW.penalty
    WHERE id_client = issued;
    RETURN NEW;
END;
$$;
 /   DROP FUNCTION public.update_debt_in_returns();
       public          postgres    false            н            1255    25227    update_on_or_probl()    FUNCTION     Э  CREATE FUNCTION public.update_on_or_probl() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
   data_del date;
  data_r date;
  pen int;
  issued int;
BEGIN
  issued:= (select cr.id_client from client_refunds as cr, issued_cars as ic
  WHERE cr.id_client = ic.id_client 
  and ic.id_issued = NEW.id_issued);
  data_del:=(select data_delivery from issued_cars where id_issued = new.id_issued);
  data_r = NEW.data_real;
  pen = new.penalty;
    IF data_r <= data_del and pen = 0 THEN
        UPDATE client_refunds
        SET on_time = on_time + 1
        WHERE id_client = issued;
    ELSE
        UPDATE client_refunds
        SET problems = problems + 1
        WHERE id_client = issued;
    END IF;
    RETURN NEW;
END;
$$;
 +   DROP FUNCTION public.update_on_or_probl();
       public          postgres    false            Ю            1255    25196    update_rental_status()    FUNCTION     ѕ   CREATE FUNCTION public.update_rental_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE cars
    SET status = 0
    WHERE id_car = NEW.id_car;
    RETURN NEW;
END;
$$;
 -   DROP FUNCTION public.update_rental_status();
       public          postgres    false            Ь            1255    25198    update_rental_status_in()    FUNCTION     V  CREATE FUNCTION public.update_rental_status_in() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  issued int;
BEGIN
  issued:= (select cars.id_car from cars, issued_cars as ic
  WHERE cars.id_car = ic.id_car 
  and ic.id_issued = NEW.id_issued) ;
    UPDATE cars
    SET status = 1
    WHERE id_car = issued;
    RETURN NEW;
END;
$$;
 0   DROP FUNCTION public.update_rental_status_in();
       public          postgres    false            м            1255    25205    update_return()    FUNCTION     ”  CREATE FUNCTION public.update_return() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  data_del date;
  data_r date;
  pen int;
  issued int;
BEGIN
  issued:= (select cr.id_client from client_refunds as cr, issued_cars as ic
  WHERE cr.id_client = ic.id_client 
  and ic.id_issued = NEW.id_issued);
  UPDATE client_refunds SET on_time = (on_time + 1) WHERE id_client = 3;
  RETURN NEW;
END;
$$;
 &   DROP FUNCTION public.update_return();
       public          postgres    false            Я            1255    25202    update_return_count()    FUNCTION     Ъ   CREATE FUNCTION public.update_return_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE client_refunds
    SET requests = requests + 1
    WHERE id_client = new.id_client;
    RETURN NEW;
END;
$$;
 ,   DROP FUNCTION public.update_return_count();
       public          postgres    false            Ч            1259    25114    bodywork    TABLE     \   CREATE TABLE public.bodywork (
    id_bodywork smallint NOT NULL,
    type character(15)
);
    DROP TABLE public.bodywork;
       public         heap    postgres    false            Ц            1259    25073    cars    TABLE       CREATE TABLE public.cars (
    id_car smallint NOT NULL,
    brand character(15),
    model character(26),
    drive character(3),
    gearbox character(3),
    bodywork smallint,
    mileage integer,
    year smallint,
    cost bigint,
    status smallint
);
    DROP TABLE public.cars;
       public         heap    postgres    false            Ш            1259    25151    client    TABLE     Н   CREATE TABLE public.client (
    id_client smallint NOT NULL,
    surname character(15),
    firstname character(15),
    middle_name character(15),
    number character(15),
    passport character(11)
);
    DROP TABLE public.client;
       public         heap    postgres    false            Щ            1259    25157    client_refunds    TABLE     ”   CREATE TABLE public.client_refunds (
    id_client smallint,
    requests smallint,
    on_time smallint,
    problems smallint,
    debt bigint
);
 "   DROP TABLE public.client_refunds;
       public         heap    postgres    false            Ъ            1259    25165 
   issued_cars    TABLE     °   CREATE TABLE public.issued_cars (
    id_issued smallint NOT NULL,
    id_car smallint,
    id_client smallint,
    data_issue date,
    data_delivery date,
    cost bigint
);
    DROP TABLE public.issued_cars;
       public         heap    postgres    false            Ы            1259    25180    real_refunds    TABLE     °   CREATE TABLE public.real_refunds (
    id_issued smallint NOT NULL,
    data_real date,
    penalty bigint,
    CONSTRAINT real_refunds_penalty_check CHECK ((penalty >= 0))
);
     DROP TABLE public.real_refunds;
       public         heap    postgres    false            %
          0    25114    bodywork 
   TABLE DATA           5   COPY public.bodywork (id_bodywork, type) FROM stdin;
    public          postgres    false    215   m?       $
          0    25073    cars 
   TABLE DATA           k   COPY public.cars (id_car, brand, model, drive, gearbox, bodywork, mileage, year, cost, status) FROM stdin;
    public          postgres    false    214   Ц?       &
          0    25151    client 
   TABLE DATA           ^   COPY public.client (id_client, surname, firstname, middle_name, number, passport) FROM stdin;
    public          postgres    false    216   лC       '
          0    25157    client_refunds 
   TABLE DATA           V   COPY public.client_refunds (id_client, requests, on_time, problems, debt) FROM stdin;
    public          postgres    false    217    G       (
          0    25165 
   issued_cars 
   TABLE DATA           d   COPY public.issued_cars (id_issued, id_car, id_client, data_issue, data_delivery, cost) FROM stdin;
    public          postgres    false    218   ‘G       )
          0    25180    real_refunds 
   TABLE DATA           E   COPY public.real_refunds (id_issued, data_real, penalty) FROM stdin;
    public          postgres    false    219   GK       …           2606    25813    bodywork bodywork_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.bodywork
    ADD CONSTRAINT bodywork_pkey PRIMARY KEY (id_bodywork);
 @   ALTER TABLE ONLY public.bodywork DROP CONSTRAINT bodywork_pkey;
       public            postgres    false    215            ѓ           2606    25802    cars cars_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.cars
    ADD CONSTRAINT cars_pkey PRIMARY KEY (id_car);
 8   ALTER TABLE ONLY public.cars DROP CONSTRAINT cars_pkey;
       public            postgres    false    214            ‡           2606    25824    client client_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (id_client);
 <   ALTER TABLE ONLY public.client DROP CONSTRAINT client_pkey;
       public            postgres    false    216            ‰           2606    25849    issued_cars issued_cars_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.issued_cars
    ADD CONSTRAINT issued_cars_pkey PRIMARY KEY (id_issued);
 F   ALTER TABLE ONLY public.issued_cars DROP CONSTRAINT issued_cars_pkey;
       public            postgres    false    218            ‹           2606    25184    real_refunds real_refunds_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.real_refunds
    ADD CONSTRAINT real_refunds_pkey PRIMARY KEY (id_issued);
 H   ALTER TABLE ONLY public.real_refunds DROP CONSTRAINT real_refunds_pkey;
       public            postgres    false    219            “           2620    25195 +   real_refunds update_debt_in_returns_trigger     TRIGGER     ‘   CREATE TRIGGER update_debt_in_returns_trigger AFTER INSERT ON public.real_refunds FOR EACH ROW EXECUTE FUNCTION public.update_debt_in_returns();
 D   DROP TRIGGER update_debt_in_returns_trigger ON public.real_refunds;
       public          postgres    false    221    219            ”           2620    25233    real_refunds update_on_or_probl     TRIGGER     Ѓ   CREATE TRIGGER update_on_or_probl AFTER INSERT ON public.real_refunds FOR EACH ROW EXECUTE FUNCTION public.update_on_or_probl();
 8   DROP TRIGGER update_on_or_probl ON public.real_refunds;
       public          postgres    false    219    237            ‘           2620    25197 (   issued_cars update_rental_status_trigger     TRIGGER     Њ   CREATE TRIGGER update_rental_status_trigger AFTER INSERT ON public.issued_cars FOR EACH ROW EXECUTE FUNCTION public.update_rental_status();
 A   DROP TRIGGER update_rental_status_trigger ON public.issued_cars;
       public          postgres    false    218    222            •           2620    25255 ,   real_refunds update_rental_status_trigger_in     TRIGGER     “   CREATE TRIGGER update_rental_status_trigger_in AFTER INSERT ON public.real_refunds FOR EACH ROW EXECUTE FUNCTION public.update_rental_status_in();
 E   DROP TRIGGER update_rental_status_trigger_in ON public.real_refunds;
       public          postgres    false    220    219            ’           2620    25204 '   issued_cars update_return_count_trigger     TRIGGER     Љ   CREATE TRIGGER update_return_count_trigger AFTER INSERT ON public.issued_cars FOR EACH ROW EXECUTE FUNCTION public.update_return_count();
 @   DROP TRIGGER update_return_count_trigger ON public.issued_cars;
       public          postgres    false    223    218            Њ           2606    25814    cars cars_bodywork_fkey 
   FK CONSTRAINT     Ќ   ALTER TABLE ONLY public.cars
    ADD CONSTRAINT cars_bodywork_fkey FOREIGN KEY (bodywork) REFERENCES public.bodywork(id_bodywork) NOT VALID;
 A   ALTER TABLE ONLY public.cars DROP CONSTRAINT cars_bodywork_fkey;
       public          postgres    false    214    3205    215            Ќ           2606    25830 ,   client_refunds client_refunds_id_client_fkey 
   FK CONSTRAINT     •   ALTER TABLE ONLY public.client_refunds
    ADD CONSTRAINT client_refunds_id_client_fkey FOREIGN KEY (id_client) REFERENCES public.client(id_client);
 V   ALTER TABLE ONLY public.client_refunds DROP CONSTRAINT client_refunds_id_client_fkey;
       public          postgres    false    216    217    3207            Ћ           2606    25803 #   issued_cars issued_cars_id_car_fkey 
   FK CONSTRAINT     „   ALTER TABLE ONLY public.issued_cars
    ADD CONSTRAINT issued_cars_id_car_fkey FOREIGN KEY (id_car) REFERENCES public.cars(id_car);
 M   ALTER TABLE ONLY public.issued_cars DROP CONSTRAINT issued_cars_id_car_fkey;
       public          postgres    false    3203    214    218            Џ           2606    25825 &   issued_cars issued_cars_id_client_fkey 
   FK CONSTRAINT     Џ   ALTER TABLE ONLY public.issued_cars
    ADD CONSTRAINT issued_cars_id_client_fkey FOREIGN KEY (id_client) REFERENCES public.client(id_client);
 P   ALTER TABLE ONLY public.issued_cars DROP CONSTRAINT issued_cars_id_client_fkey;
       public          postgres    false    3207    218    216            ђ           2606    25850 (   real_refunds real_refunds_id_issued_fkey 
   FK CONSTRAINT     –   ALTER TABLE ONLY public.real_refunds
    ADD CONSTRAINT real_refunds_id_issued_fkey FOREIGN KEY (id_issued) REFERENCES public.issued_cars(id_issued);
 R   ALTER TABLE ONLY public.real_refunds DROP CONSTRAINT real_refunds_id_issued_fkey;
       public          postgres    false    218    3209    219            %
   Y   xњ3дLО/-HUЂ.#ОвФ”Д<$cОьґ4ЭўьД€	'€W\’Z1еLNL*КМПI-ЃЉq–$Ґ'"™cО™‘X’њ‘”њ
‰Сгвв °tђ      $
     xњ•VMsЈF<?э
ЋЙA	у	s”еШЩ*“rIЪН&•Л¬4kS…А5 W)ї>¤AЮ
 ы икоЧпѓИцOЪљ2кxЬE7Шьy«l hЗш‡Ж@dЬ=@DA¦kcu“{0«ЛЭЙжх±љЫE–ЉЊPHрi±вЈ°*ѕлhSЌы¶Ќ)Юуkњо§UЏЕ@tґ©g/xH”"Юю@" F‰”--„¦Up_^Мд“/щ›±Сvі[’x-C^sЋЕ)¤Јa1<W¶Юїz8Xлі)K…ь&"‘Љlя‹ЉIШ™єР“чік`
zЄК—hЈЛ‘ґ‡ўАx_IЪ•Б‰Dь'}ьVЩ—ЧјМЭп¦lфЎІ7xu© BqЮZЖЂ
ЇCr‹'у®ЛЖX*№‹E\BјяюИлZ—гЏ»ежF5Gj]J[j’t`–@fмЮLн=Узozя‰4ћЕк<$ЋeЊ%}¬N‡|ъЕ&Ќѕ`$ћЌэ^ЩЈ.ч&ъф)ъ‰oћДЊP_ ’&Jх2I упyЌСE+о’‘ЋБаЇUк2!ДMч‘Њt¤hм;‰‰ к·ec«2љ™ЁЦЁNЯШ”TВCeУчіSЭ`HoйЛ:}ўk#ў¤‚DщЂ!-{Є'lM©›yЇ®iaОI…мђдН@ИЏЃ5t
™rиmф¶"$Zkk±"bµ
$Lt
• е2x0ЦjлЅ‡ ~НgЖ-ЪFЅЕЉAeD»’ялЅЛ–НD%Шr г3CЌ¶†чf8)pbuМ€іГЄn0O™¶MЮfопФG:‡Ф‹aё’Q'о“™йЉ}€q
Жлd·1жзNм+ ќё™…эOгШЎ	п'…yЙ`єю~Іz?iц,њЉuЫЌ$]пxWќ«fдЫУ›ќ§6© лЪ Й±йЌ5тЧЕ›rлfµЊ]/%ЙЂ”­фёЬє®Ї9]%Њ¦эeЎh[ЧNd
wё
sKY•‘v)WгЗЈ—SЊQЈ
bс¬K}мєт:Юю¤MVїuвНѓўЁ—›кмlБW~ҐБ\Ѕ4_@ЇK±ц0|1!g±.РHЏ&ыmТsг·m^јг©І.ЄУaН
іTхh1О"џ‹дF.ѕ~t^0ђгuбMc*8ИІgѕ$t}K¦л%ЮoJґ‰ЊщЗnёо¦ПЛ ,§»Ў$uh
·шњќй:ZWЗ7УдяжU9ЅYјix,єtД&Ё§–ФuQh{9b'Cѓ
·b2YrxЁkФUзC
аЋМ‹јЌЮ2:ћwlv5нґ}	[Ау’Э>к гx+юуЛb±шЎБ`П      &
     xњЌ•]nУ@Зџі§р@»Юп»p6КC%
QиC_а	Ґ
nS—+ЊoДЖЋіN›–H±ґЮхьfюу±fF'tO+ьwпйљ®Єю7Јoґ Ыnџє«Єсн1µ8№‡“8KMw8lД¬m4Цб'kS[WщSЦЄжПnp|A єЪX;ГІнц»9¶Z<j‡ќSZТЅp

cLЂUзkЫЇѓwА);ЈЭAчЋорХjЛ±¬9љkєЩа‹ЩЇЊ)Gv_ЦЮЩzЌcЙtзє-в¦ЫD‹ќіЎ/хFд У¶ЧН#јJз„А” ©; KZфB”Ћ7ЭXkhUджВhєщѓм ЋцБjY«l *”Я5;Tьюђ¶аdќЧ л+F;с]w„"cНЪ‰nї=*¶«4FЩf1iЌd -ANKўx“J3ъLqоµёНЯ,
Э$¦vэк‘љч$–*y·Ћ&UЊrVе}A^цaЋkбнFёЭќі©Б-СЊ·:‡и“¬™YХ`Е ЊF+HЉьпf|—cwґНрЮҐјоыЖЋОN3ЈЇ\ceSsУzFє¶мW›Ц„ЕЎ’‘Џѕ’Ј25#k№ UeЭ‹ EЦLтТЏф}ТfHKЉ•¶ЪkЇЊнҐ№‘б1™5ЯҐ].Ё‚їsОЂсф~`8_сГЃбъњK-Ј._РЧФS'ѓд;+m/ЄґЧ1ѓ0 ОбЫЄ„­ќА;Ѕњже\ґ\NFЩђҐђыъти¦‚2hя
Н=сoўі9мЭ•дS™внCwЉИУЛЕ,Нc )ѓЖяС#ъq9
ГЌz
0(’еMз=Х’h”bи іЬ7Xaд(ѓОяЙз»CiqАћIюв4Q7 
 КЙ	•ЏЩЕ¬Lж©Мћ]
Ґ]ЯbY’Ђ/
О3n(іњpќ…њ’Є5Џk\™НЦј:cµd4–;»о9Б$ФЪqёgjЏpЌк¬^ЅTJэPПh.      '
   z   xњEЋЙГ@ЯЊk8ҐНЕщЗaАТоoєҐ 'Ў АЧ°Ґl…A рMYЄP/_ѕ>tj•ц±щV±›І-‚—эЦ"§Д‘«fЊ”DWЕX1™ве=+V¬{WтAэгuЉо#}d›І;EжCлефѓїfюЯз#ф      (
   ¦  xњuW[¶$)ьЦЅфy)оeцїЋ¬®„њт~y*##И‹
4H†ьл9оЖ›g‡’ЋlGялФ(A@ћЈ¶=ВmZЄп«й8Ы°@]ЪJП‘/X<ъl –лW1Т`«gZ
0cф‰cС!0ЪЂжч€ЈСЉЉwіџщ‰C™&¦АX‘°

МSdьi=Ў=І««Ѓј¶&•Ьп
а”dE#&`ѕИ;h^duђYT”џЛхpV4aRЭ~<ЙV#hл"¬ђ6ВЄТџ»нFійMЫC@Ё“AE\ ·фѕdC9ЃИЌ?.В)Т±ќAE8ZD;Љ›~jbпгIз7Л DЖ6яЏmжFwR~ќ2ћц‰¤¦~R|%z@бЭьЁ6У1/…yS·V§Р
…Й-ЪjOgы.fGЎ{<хСЫљСvdLн–/_®"b<ђЧЭІЫjп`ЁLв~ЃЯ:[Љк]'M†©ќю1ЊЕ1WеP« ¶3С
Вћв’G4–eЈ]P%кє¶Kэ<xh0;aHЭ-™dМSћIBBЃї[Iрчhї’ё­Ѕћ ‰{†·:“»%UБt:”Щ9в_‘ЬJG<цъУ€К‘ј™b °ЅЙґКЭFЁВцгNг§’#фeЈ›Zй¦ДЂqґ”;п
ЄР[]†
§7
NЛXAыg6ъ®1фNЯ7љО’Љ®
>kJШ[=ЈJ¬Пў±lрЫ&* ›у ЈЉџЂC‰y—є!“Ngљ‰ъ<И(Н±jыFЛЅ[ШъLфiЕ–QхvU1БЧЬДК=_†PНxFя$_kyј2»E_Ны°
ц›вНЁZЧщц™–@Zќ›№ЯЧрЙ1mЖ—±WYэK} е‹ХЫбБ№ЭМP$>Зй2У±ЇсЋҐ™‰П ]ѕктD{ЕЉйР—wЫwММg—bнцepщ6вDВѕP»Рф<IAн®z"‰cЅЂЂeЈЃж
$ПСЉ`·s_Aыь	ъ~x­0МѕЂи4ПЪ.sz2
ФDЧіtЗOФnrШФшd(х~Ћц®н#°+6JцFс€
кYє‹щў|№іС•э
д†:¦A;м
Љ‚‰®УW3Ћ|±„В;PГT@y4<М[,Qнj~OЭъФщўn?Рк,§яр<Ф'ж|OхІ6Жdю<YЏ“ЧЗ¤[FячџЮы¶BЈ      )
   P  xњe”Й‘! ЯC.ЮТ
дІщЗaD•­ГПF µ3шї@_ 
Ь щ‹ёЂ!?++ћБ"ѓњҐѓ;ўу B„}7¦ъЛ9	іT]Фк‹–хЬCnЋU…qWc‚ЄLTчWgТМІnQJ}{Јґ~ЕhЧД­9ь2ЎЗ)ѓnжZ‡Лэ.·cлћ™y
Ѓд,†Яйяёac©.d9ЋКЫNв.l5	ЇЯtebдУ”{I9э6$†@Ю pгeЇ)љХо#¶Vd6‰$Кзр¦!»VRhЊщРaЄ&КµЁJfјghи’їm¦ЪLuµш®UВ°о7jы№н—кcЪО[х±Щв+ЙрЊМж4?Nц‚л°+OjМЌ%Ш§лз}O‹EяPжцЫ›«с®ј Шя4+¤оwjЮЩВјhлјрся7ЖxнАд±     