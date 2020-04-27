---
title: Adding a GUID column via migrations in Orchard
tags:
- orchard
date: 2016-02-10
---
Generally when adding a column in Orchard CMS you do this:

    .Column<string>("MyString", column => column.NotNull())

However, if you try doing that with a GUID it wont work, you need to explicitly set the database type like this:

    .Column("MyGuid", DbType.Guid, column => column.NotNull().Unique())

I'm not sure if there is a reason for this irregularity or if it is just a bug. Maybe I'll look into it one day.