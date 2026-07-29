-- The Volt Database Schema for Supabase
-- Run this in the Supabase SQL Editor

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Profiles table (extends Supabase auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text unique not null,
  display_name text,
  avatar_url text,
  preferred_styles text[] default '{}',
  is_pro boolean default false,
  daily_generations_used int default 0,
  last_generation_date timestamptz default now(),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Wardrobe items table
create table public.wardrobe_items (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  name text not null,
  category text not null check (category in ('tops', 'bottoms', 'shoes', 'outerwear', 'accessories')),
  color text not null,
  material text,
  brand text,
  style text check (style in ('casual', 'formal', 'streetwear', 'athletic', 'smart', 'vintage')),
  image_url text not null,
  transparent_image_url text,
  suitable_seasons text[] default '{}',
  warmth_rating int default 5 check (warmth_rating between 1 and 10),
  created_at timestamptz default now()
);

-- Outfits table
create table public.outfits (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  name text,
  top_id uuid references public.wardrobe_items(id) on delete set null,
  bottom_id uuid references public.wardrobe_items(id) on delete set null,
  shoes_id uuid references public.wardrobe_items(id) on delete set null,
  outerwear_id uuid references public.wardrobe_items(id) on delete set null,
  accessory_ids uuid[] default '{}',
  rating int check (rating between 1 and 5),
  is_saved boolean default false,
  weather_condition text,
  temperature numeric,
  created_at timestamptz default now()
);

-- Outfit calendar (scheduled outfits)
create table public.outfit_calendar (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  outfit_id uuid references public.outfits(id) on delete cascade not null,
  scheduled_date date not null,
  created_at timestamptz default now(),
  unique(user_id, scheduled_date)
);

-- RLS policies
alter table public.profiles enable row level security;
alter table public.wardrobe_items enable row level security;
alter table public.outfits enable row level security;
alter table public.outfit_calendar enable row level security;

-- Profiles: users can only read/update their own
create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- Wardrobe items: users can CRUD their own
create policy "Users can view own wardrobe"
  on public.wardrobe_items for select
  using (auth.uid() = user_id);

create policy "Users can insert own wardrobe"
  on public.wardrobe_items for insert
  with check (auth.uid() = user_id);

create policy "Users can update own wardrobe"
  on public.wardrobe_items for update
  using (auth.uid() = user_id);

create policy "Users can delete own wardrobe"
  on public.wardrobe_items for delete
  using (auth.uid() = user_id);

-- Outfits: users can CRUD their own
create policy "Users can view own outfits"
  on public.outfits for select
  using (auth.uid() = user_id);

create policy "Users can insert own outfits"
  on public.outfits for insert
  with check (auth.uid() = user_id);

create policy "Users can update own outfits"
  on public.outfits for update
  using (auth.uid() = user_id);

create policy "Users can delete own outfits"
  on public.outfits for delete
  using (auth.uid() = user_id);

-- Calendar: users can CRUD their own
create policy "Users can view own calendar"
  on public.outfit_calendar for select
  using (auth.uid() = user_id);

create policy "Users can insert own calendar"
  on public.outfit_calendar for insert
  with check (auth.uid() = user_id);

create policy "Users can update own calendar"
  on public.outfit_calendar for update
  using (auth.uid() = user_id);

create policy "Users can delete own calendar"
  on public.outfit_calendar for delete
  using (auth.uid() = user_id);

-- Storage buckets
insert into storage.buckets (id, name, public) values ('wardrobe-images', 'wardrobe-images', true);
insert into storage.buckets (id, name, public) values ('avatars', 'avatars', true);

-- Storage policies
create policy "Anyone can view wardrobe images"
  on storage.objects for select
  using (bucket_id = 'wardrobe-images');

create policy "Users can upload wardrobe images"
  on storage.objects for insert
  with check (bucket_id = 'wardrobe-images' and auth.uid() is not null);

create policy "Users can view own avatar"
  on storage.objects for select
  using (bucket_id = 'avatars');

create policy "Users can upload own avatar"
  on storage.objects for insert
  with check (bucket_id = 'avatars' and auth.uid() is not null);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, display_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1))
  );
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
