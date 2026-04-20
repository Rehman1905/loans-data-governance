--Domain:Loans
create table customers(
customer_id number primary key,
first_name varchar2(50),
last_name varchar2(50),
middle_name varchar2(50),
serial_number varchar2(20) UNIQUE,
date_of_birth date,
phone_number varchar2(20),
email varchar2(100),
internal_score number ,
created_date date default current_date
);

create table loan_account (
loan_id number primary key,
customer_id number,
loan_type varchar2(20),
principal_amount number,
interest_rate number,
term_months number,
start_date date,
end_date date,
loan_status varchar2(20),
outstanding_balance number,
created_date date default current_date,
foreign key(customer_id) references customers(customer_id)
);
create table loan_payment (
payment_id number,
loan_id number,
due_date date,
payment_date date,
amount_due number,
amount_paid number,
payment_method varchar2(20),
payment_status varchar2(20),
created_date date default current_date,
foreign key(loan_id)references loan_account(loan_id)
);


-- TAKS7 AND TASK8
with base as (
select
count(*) total_cnt,

-- serial_number
count(c.serial_number) serial_cnt,
count(distinct c.serial_number) serial_dist,
count(case when regexp_like(c.serial_number,'^(AA|AB)[0-9]{7}$|^AZE[0-9]{8}$') then 1 end) serial_valid,

-- internal_score
count(c.internal_score) score_cnt,
count(case when c.internal_score between 1 and 100 then 1 end) score_valid,

-- principal_amount
count(la.principal_amount) principal_cnt,
count(case when la.principal_amount>0 then 1 end) principal_valid,

-- interest_rate
count(la.interest_rate) rate_cnt,
count(case when la.interest_rate>0 and la.interest_rate<1 then 1 end) rate_valid,

-- loan_status
count(la.loan_status) lstatus_cnt,
count(case when la.loan_status in('ACTIVE','CLOSED','DEFAULT','DELINQUENT') then 1 end) lstatus_valid,

-- outstanding_balance
count(la.outstanding_balance) balance_cnt,
count(case when la.outstanding_balance>=0 then 1 end) balance_valid,
count(case when la.outstanding_balance<=la.principal_amount then 1 end) balance_consistent,
count(case when abs(la.outstanding_balance-(la.principal_amount-nvl(paid.total_paid,0)))<=0.01 then 1 end) balance_accurate,

-- payment_status
count(lp.payment_status) pstatus_cnt,
count(case when lp.payment_status in ('PAID','PARTIAL','MISSED','PENDING') then 1 end) pstatus_valid,
count(case
when lp.payment_status='PAID' and lp.amount_paid=lp.amount_due then 1
when lp.payment_status='MISSED' and lp.amount_paid=0 then 1
when lp.payment_status='PARTIAL' and lp.amount_paid>0 and lp.amount_paid<lp.amount_due then 1
when lp.payment_status='PENDING' then 1 end) pstatus_consistent,

-- amount_paid
count(lp.amount_paid) paid_cnt,
count(case when lp.amount_paid>=0 then 1 end) paid_valid,
count(case when lp.amount_paid<=lp.amount_due then 1 end) paid_consistent,
count(case when lp.payment_status!='PAID' or abs(lp.amount_paid-lp.amount_due)<=0.01 then 1 end) paid_accurate
from customers c
left join loan_account la on c.customer_id=la.customer_id
left join loan_payment lp on la.loan_id=lp.loan_id
left join(select loan_id,sum(amount_paid) total_paid
from loan_payment
where payment_status in('PAID','PARTIAL')
group by loan_id
)paid on la.loan_id=paid.loan_id
),
scores as(
select
col.column_name,
round(case
when col.column_name='serial_number' then serial_cnt
when col.column_name='internal_score' then score_cnt
when col.column_name='principal_amount' then principal_cnt
when col.column_name='interest_rate' then rate_cnt
when col.column_name='loan_status' then lstatus_cnt
when col.column_name='outstanding_balance' then balance_cnt
when col.column_name='payment_status' then pstatus_cnt
when col.column_name='amount_paid' then paid_cnt
end*100/total_cnt,2) as completeness_score,
round(case
when col.column_name='serial_number' then serial_dist/serial_cnt
end*100,2) as uniqueness_score,
round(case
when col.column_name='serial_number' then serial_valid/serial_cnt
when col.column_name='internal_score' then score_valid/score_cnt
when col.column_name='principal_amount' then principal_valid/principal_cnt
when col.column_name='interest_rate' then rate_valid/rate_cnt
when col.column_name='loan_status' then lstatus_valid/lstatus_cnt
when col.column_name='outstanding_balance' then balance_valid/balance_cnt
when col.column_name='payment_status' then pstatus_valid/pstatus_cnt
when col.column_name='amount_paid' then paid_valid/paid_cnt
end*100,2) as validity_score,
round(case
when col.column_name='outstanding_balance' then balance_consistent/balance_cnt
when col.column_name='payment_status' then pstatus_consistent/pstatus_cnt
when col.column_name='amount_paid' then paid_consistent/paid_cnt
end*100,2) as consistency_score,
round(case
when col.column_name='outstanding_balance' then balance_accurate/balance_cnt
when col.column_name='amount_paid' then paid_accurate/paid_cnt
end*100,2) as accuracy_score
from base
cross join(
select 'serial_number' as column_name from dual union all
select 'internal_score' from dual union all
select 'principal_amount' from dual union all
select 'interest_rate' from dual union all
select 'loan_status' from dual union all
select 'outstanding_balance' from dual union all
select 'payment_status' from dual union all
select 'amount_paid' from dual
)col)
select
column_name,
completeness_score,
uniqueness_score,
validity_score,
consistency_score,
accuracy_score,
round(case
when column_name='serial_number' then (completeness_score+uniqueness_score+validity_score)/3
when column_name in('internal_score','principal_amount','interest_rate','loan_status') then (completeness_score+validity_score)/2
when column_name='outstanding_balance' then (completeness_score+validity_score+consistency_score+accuracy_score)/4
when column_name='payment_status' then (completeness_score+validity_score+consistency_score)/3
when column_name='amount_paid' then (completeness_score+validity_score+consistency_score+accuracy_score)/4
end,2) as cde_score,
round(avg(case
when column_name='serial_number' then (completeness_score+uniqueness_score+validity_score)/3
when column_name in('internal_score','principal_amount','interest_rate','loan_status') then (completeness_score+validity_score)/2
when column_name='outstanding_balance' then (completeness_score+validity_score+consistency_score+accuracy_score)/4
when column_name='payment_status' then (completeness_score+validity_score+consistency_score)/3
when column_name='amount_paid' then (completeness_score+validity_score+consistency_score+accuracy_score)/4
end) over(),2) as overall_dq_score
from scores
order by cde_score desc;
--TASK9
create or replace procedure sp_update_loan_status(
p_loan_id in loan_account.loan_id%type,
p_new_status in loan_account.loan_status%type,
p_updated_by in varchar2,
p_result_code out number,
p_result_msg out varchar2
)as
v_current_status loan_account.loan_status%type;
v_loan_exists number:=0;
begin
select count(*)
    into v_loan_exists
    from loan_account
    where loan_id=p_loan_id;

    if v_loan_exists=0 then
        p_result_code:=-1;
        p_result_msg:='XETA: '||p_loan_id||'ID-li kredit tapilmadi.';
        return;
    end if;

    if p_new_status not in('ACTIVE','CLOSED','DEFAULT','DELINQUENT') then
        p_result_code:=-2;
        p_result_msg:='XETA: '||p_new_status||' etibarsiz status deyeridir.';
        return;
    end if;

    select loan_status
    into v_current_status
    from loan_account
    where loan_id=p_loan_id;

    if v_current_status=p_new_status then
        p_result_code:=-3;
        p_result_msg:='XETA: Kredit artiq '||p_new_status||' statusundadir.';
        return;
    end if;

    if v_current_status='CLOSED' then
        p_result_code:=-4;
        p_result_msg:='XETA: Bagli kredit yeniden aktivlesdirile bilmez.';
        return;
    end if;

    update loan_account
    set loan_status=p_new_status
    where loan_id=p_loan_id;

    commit;
    p_result_code:=0;
    p_result_msg:='UGURLU: '||p_loan_id||' krediti '||v_current_status||' -> '||p_new_status||' olaraq yenilendi.';

exception
    when others then
        rollback;
        p_result_code:=-99;
        p_result_msg:='SISTEM XETASI: '||sqlerrm;
end sp_update_loan_status;
/

--example
declare
    v_code number;
    v_msg  varchar2(500);
begin
    sp_update_loan_status(
        p_loan_id=>1,
        p_new_status=>'DELINQUENT',
        p_updated_by=>'test_user',
        p_result_code=>v_code,
        p_result_msg=>v_msg
    );
    dbms_output.put_line('Kod: '||v_code);
    dbms_output.put_line('Mesaj: '||v_msg);
end;
/

commit;
