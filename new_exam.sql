--1:gsearch seems to be the biggest driver of our business could you pull monthly trends for gsearch sessions and orders so that we can  showcase the growth there:

select * from website_session
select * from orders

create view df1 as 
select  website_session.website_session_id,utm_source,utm_campaign,utm_content,device_type,orders.order_id,items_purchased,website_session.created_at,month(website_session.created_at) as month,price_usd  from website_session
full outer join orders
on website_session.website_session_id=orders.website_session_id
where website_session.created_at<'2012-11-27'

select month,count(order_id) as number_of_orders,count(website_session_id) as number_of_sessions from df1
where utm_source='gsearch'
group by  month
order by month asc

--2:it would be great to see a similar monthly trend fo gsearch,but this time splitting out nonbrand and brand compaigns separately.I am wondering if brand is picking up at all.if so,this is a good stroy to tell!

select * from df1
select month,utm_campaign,count(order_id) as number_of_orders,count(website_session_id) as number_of_sessions  from df1
where utm_source='gsearch' 
group by month,utm_campaign
order by month asc


select month,sum(case when utm_campaign='nonbrand' and order_id is not null  then 1 else 0 end) as number_of_orders_nonbrand,sum(case when utm_campaign='brand' and order_id is not null then 1 else 0 end) as number_of_orders_brand ,

count(case when utm_campaign='nonbrand' then website_session_id else null end) as number_of_session_nonbrand,count(case when utm_campaign='brand' then website_session_id else null end) as number_of_session_brand 

from df1
where utm_source='gsearch' 
group by month
order by month asc
--3:while we are on gsearch,could you dive into nonbrand,and pull monthly sessions and orders split by device type?I want to flex our analytical muscles a littl and show the board we really know our traffic sources.
select * from df1
select month,sum(case when  device_type='desktop' then 1 else 0  end) as session_desktop ,
sum(case  when order_id is not null and device_type='desktop' then 1 else 0  end)as order_desktop,
sum(case when  device_type='mobile' then 1 else 0  end) as session_mobile ,

sum(case  when order_id is not null and device_type='mobile' then 1 else 0  end) as order_mobile,

count(website_session_id) as total_sessionn    from df1
where utm_source='gsearch' and utm_campaign='nonbrand'
group by month
order by month asc
--4:I am worried that one of our more pessimistic board members may be concerned about the large % of traffic  from gsearch.can you pull monthly trends for gsearch,alongside monthly trends for each of our other channels?


select distinct utm_source from df1


select month,
count(case when utm_source='gsearch'  then website_session_id else null end) as gshearch_session,
count(case when utm_source='gsearch' and order_id is not null then website_session_id else null end) as gshearch_session_order,
count(case when utm_source='bsearch' then website_session_id else null end) as bsearch_session,
count(case when utm_source='bsearch' and order_id is  not null then website_session_id else null end) as bshearch_session_order,
count(case when utm_source is null  then website_session_id else null end) as without

from df1
group by month
order by month
--5:I would like to tell the story of our website performance improvements over the course of the first  months.could you pull session to order conversion rates ,by month?
select * from df1
select * from websiter_pageviews

create view df2 as
select df1.website_session_id,utm_source,utm_campaign,utm_content,device_type,order_id,items_purchased,df1.created_at,month,website_pageview_id,pageview_url from df1
full outer join websiter_pageviews
on websiter_pageviews.website_session_id=df1.website_session_id
where  websiter_pageviews.created_at<'2012-11-27'

select * from df2

select month,count(website_session_id) as session_amount,count(order_id) as order_amount
from df2
group by month
order by month  asc
--6:For the gsearch lander test,please estimate the revenue that test earned us:
select * from df1
select * from  websiter_pageviews
create view df3 as
select df1.website_session_id,utm_source,utm_campaign,utm_content,device_type,order_id,items_purchased,df1.created_at,month,website_pageview_id,pageview_url,price_usd from df1
full outer join websiter_pageviews
on websiter_pageviews.website_session_id=df1.website_session_id
where  websiter_pageviews.created_at>'2012-06-19' and websiter_pageviews.created_at<'2012-07-28' and utm_source='gsearch' and utm_campaign='nonbrand'

select * from df3

create view df4 as 
select website_session_id,min(website_pageview_id) as first_page from df3
group by website_session_id


select * from df3
select * from df4


create view df5 as 
select df3.website_session_id,pageview_url,order_id from df3 
full outer join df4
on df3.website_pageview_id=df4.first_page


select pageview_url,count(website_session_id),count(order_id) from df5
group by pageview_url
having pageview_url in ('/home','/lander-1')

--7:For the landing page test you analyzed previously,it would be great to show a full conversion funnel from each of the two pages to orders.you can use the same time period you analyzed last time.
select * from df3
select * from df4

select distinct pageview_url from df3

create view df6 as
select df3.website_session_id,device_type,order_id,items_purchased,created_at,month,website_pageview_id,pageview_url,price_usd,first_page from df3 
full outer join df4
on df3.website_pageview_id=df4.first_page


create view df7 as 
select 
website_session_id,
sum(case  when pageview_url='/home' then 1 else 0 end) as home,
sum(case  when pageview_url='/lander-1' then 1 else 0 end) as lander1,
sum(case  when pageview_url='/thank-you-for-your-order' then 1 else 0 end) as thankyou,
sum(case  when pageview_url='/billing' then 1 else 0 end) as billing,
sum(case  when pageview_url='/cart' then 1 else 0 end) as cart,
sum(case  when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end) as mrfuzzy,
sum(case  when pageview_url='/products' then 1 else 0 end) as product,
sum(case  when pageview_url='/shipping' then 1 else 0 end) as shipping

from df6
group by website_session_id

select * from df7

create view  df8 as 
select 
website_session_id,
case when home=1 then 'saw_home'
     when lander1=1 then 'saw_lander'
	 else 'ooops'
end as segment,
thankyou,billing,cart,mrfuzzy,product,shipping

from df7


select * from df8

select segment,COUNT(website_session_id),sum(thankyou),sum(billing),sum(cart),sum(mrfuzzy),sum(product),sum(shipping) from df8
group by segment


--8:I would love for you to quantify the impact of our billing test,as well.sep10-nov10
create view mf1 as
select df1.website_session_id,order_id,items_purchased,df1.created_at,month,price_usd,website_pageview_id,pageview_url from df1
full outer join websiter_pageviews
on df1.website_session_id=websiter_pageviews.website_session_id;

create view mf2 as 
select website_session_id,min(website_pageview_id) as first_page from mf1
group by website_session_id;


create view mf3 as
select mf1.website_session_id,order_id,items_purchased,mf1.created_at,month,price_usd,website_pageview_id,pageview_url,first_page from mf1
full outer join mf2
on mf1.website_pageview_id=mf2.first_page


select distinct pageview_url from mf3

select pageview_url,count(website_session_id) as session ,sum(price_usd) as revenue from mf3
where pageview_url in ('/billing','/billing-2') and created_at>'2012-09-27' and created_at<'2012-11-10'
group by pageview_url

