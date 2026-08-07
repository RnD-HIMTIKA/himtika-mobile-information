CREATE TABLE IF NOT EXISTS public.himtika_kabinet (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nama_kabinet TEXT NOT NULL,
    tagline TEXT,
    deskripsi TEXT,
    logo_url TEXT,
    periode VARCHAR(20) NOT NULL, -- Contoh: "2024/2025"
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.himtika_about (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    visi TEXT NOT NULL,
    misi JSONB NOT NULL DEFAULT '[]'::jsonb, -- Array string poin-poin misi
    sejarah_text TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.himtika_divisi (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nama_divisi TEXT NOT NULL, 
    deskripsi TEXT,
    logo_url TEXT,
    urutan INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.himtika_pengurus (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    divisi_id UUID REFERENCES public.himtika_divisi(id) ON DELETE CASCADE,
    nama TEXT NOT NULL,
    jabatan TEXT NOT NULL,
    foto_url TEXT,
    urutan INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.himtika_kabinet ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.himtika_about ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.himtika_divisi ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.himtika_pengurus ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public Read Kabinet" ON public.himtika_kabinet FOR SELECT USING (true);
CREATE POLICY "Public Read About" ON public.himtika_about FOR SELECT USING (true);
CREATE POLICY "Public Read Divisi" ON public.himtika_divisi FOR SELECT USING (true);
CREATE POLICY "Public Read Pengurus" ON public.himtika_pengurus FOR SELECT USING (true);

CREATE POLICY "Admin All Access Kabinet" ON public.himtika_kabinet FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin All Access About" ON public.himtika_about FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin All Access Divisi" ON public.himtika_divisi FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin All Access Pengurus" ON public.himtika_pengurus FOR ALL USING (auth.role() = 'authenticated');

INSERT INTO public.himtika_kabinet (nama_kabinet, tagline, deskripsi, periode, is_active)
VALUES (
    'SINERGIS',
    'Sinergi, Inovatif, Eksplorasi, Responsif, Generalis, Sistematis',
    'Kabinet SINERGIS HIMTIKA periode 2024/2025 berfokus pada kolaborasi dan inovasi teknologi.',
    '2024/2025',
    true
) ON CONFLICT DO NOTHING;

INSERT INTO public.himtika_about (visi, misi, sejarah_text)
VALUES (
    'Mewujudkan HIMTIKA sebagai wadah pengembangan potensi mahasiswa Informatika UNSIKA yang berintegritas, inovatif, dan berdaya saing.',
    '["Menyelenggarakan kegiatan akademik dan non-akademik yang berkualitas", "Membangun hubungan internal dan eksternal yang sinergis", "Mengembangkan inovasi riset dan teknologi di lingkungan kampus"]'::jsonb,
    'HIMTIKA (Himpunan Mahasiswa Teknik Informatika) didirikan di Universitas Singaperbangsa Karawang sebagai wadah pemersatu dan aspirasi seluruh mahasiswa Informatika.'
) ON CONFLICT DO NOTHING;
