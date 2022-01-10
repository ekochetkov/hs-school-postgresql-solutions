# PG internal commands summary

## Logical

Get default prefix for search tables and etc.:
```sql
show search_path;
```

## Physical

Get physical path for table `file_test`:
```sql
select pg_relation_filepath('file_test');
```

## TableSpaces

Create new tablespace `newtblspc` on location `/data/newtblspc`:
```sql
create tablespace newtblspc location '/data/newtblspc'
```

Create table in new tablespace:
```sql
create table if not exists another_tbl (id int) tablespace newtblspc;
```

## Pages

[PageInspect](https://postgrespro.ru/docs/postgrespro/12/pageinspect) - module provides functions that allow you to inspect the contents of database pages at a low level.
```sql
create extension if not exists pageinspect;
```

[Page Header data](https://postgrespro.ru/docs/postgrespro/13/storage-page-layout?lang=en)
```sql
select * from page_header(get_raw_page('another_tbl', 0));
select * from heap_page_items(get_raw_page('another_tbl', 0));
```

## MVCC

Get base info about mvcc state for table `mvcc_test`.
```sql
select lp, t_xmin, t_xmax, t_ctid, t_data
  from heap_page_items(get_raw_page('mvcc_test', 0));
```

### Vacuum

`Bloat` table - increase table size by work mvcc mechanism.

Clear not actual mvcc records:
```sql
vacuum mvcc_test;
```

Delete not actual mvcc records (need lock table!)
```sql
vacuum full mvcc_test;
```

### Isolation levels

* Read uncommitted - read not committed rows
* Read committed - default data shaphot for each operator/command read only committed rows

Repeatable read Data shaphot for first operator.
Set isolation level syntax example:
```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- Get data shanpshot
SELECT count(*) from patient;
-- <-    inser into patient ; commit;
SELECT count(*) from patient;
END;
```

## WAL write-ahead log

Journal, write first (fsync) not for temp and unlogged tables Sync / Async - fsync Wal Levels:
 * Minimal
 * Replica
 * Logical

```sql
select pg_current_wal_lsn();
select pg_walfile_name(pg_current_wal_lsn());
select * from pg_ls_waldir() limit 10;
```

## Checkpoint

Checkpointer process - dump all buffers to disc (fsync)

To create checkpoint simple execute:
```sql
checkpoint
```