# Generated by Django 3.1.4 on 2021-01-02 20:05

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("shops", "0002_auto_20201221_2023"),
    ]

    operations = [
        migrations.AddField(
            model_name="shop",
            name="reference",
            field=models.CharField(blank=True, max_length=200),
        ),
        migrations.RunSQL(
            """CREATE OR REPLACE FUNCTION shop_id_sequence_for_year() RETURNS trigger
                               LANGUAGE plpgsql AS
                            $$DECLARE
                               seqname text := 'shop_reference_' || extract('year' from now());
                            BEGIN
                                EXECUTE 'CREATE SEQUENCE IF NOT EXISTS ' || seqname || ' START 10000';
                                NEW.reference := (Concat('bonobo-', EXTRACT('year' from now()), '-', (select nextval(seqname))));
                                RETURN NEW;
                            END;$$;
                            DROP TRIGGER IF EXISTS shop_id_sequence_for_year on shops_shop; 
                            CREATE TRIGGER shop_id_sequence_for_year_trigger BEFORE INSERT ON shops_shop FOR EACH ROW
                                EXECUTE PROCEDURE shop_id_sequence_for_year();""",
            reverse_sql="""
            --- Drop sequences ---
            delete FROM pg_class where relname like 'shop_reference_%' and relkind = 'S';
            delete from pg_type where typname like 'shop_reference_%';
            --- DROP trigger ---
            drop trigger shop_id_sequence_for_year_trigger on shops_shop;
            --- Drop function ---
            drop function shop_id_sequence_for_year;
            """,
        ),
    ]
