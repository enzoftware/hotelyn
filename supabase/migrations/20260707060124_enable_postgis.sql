-- Enable PostGIS so geospatial columns/queries (e.g. nearby-hotel search) are
-- available from the very first migration onward.
create extension if not exists postgis with schema extensions;
