# BY Construction News Bot - Daily Poster
# Publishes 3 construction news posts to WordPress with Pexels images

$ErrorActionPreference = "Stop"

# --- Credentials ---
$creds = Get-Content "C:\Users\Wizard\.openclaw\credentials.json" | ConvertFrom-Json
$wpUrl = $creds.wordpress.url
$wpUser = $creds.wordpress.username
$wpPass = $creds.wordpress.password
$pexelsKey = $creds.pexels.api_key

$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${wpUser}:${wpPass}"))
$wpHeaders = @{
    "Authorization" = "Basic $base64Auth"
    "Content-Type"  = "application/json"
}

# --- Helper: Download image to temp ---
function Get-ImageFile($url, $filename) {
    $tmpPath = "C:\Users\Wizard\AppData\Local\Temp\$filename"
    try {
        Invoke-WebRequest -Uri $url -OutFile $tmpPath -Headers @{"User-Agent"="Mozilla/5.0"} -TimeoutSec 30
        return $tmpPath
    } catch {
        Write-Host "[WARN] Could not download $url"
        return $null
    }
}

# --- Helper: Upload to WordPress media library ---
function Add-WpMedia($filePath, $altText) {
    if (-not $filePath) { return $null }
    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    $base64Content = [Convert]::ToBase64String($fileBytes)
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $mimeType = "image/jpeg"

    $body = @{
        filename = $fileName
        mimeType = $mimeType
        base64EncodedContents = $base64Content
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$wpUrl/wp-json/wp/v2/media" `
        -Headers $wpHeaders `
        -Method Post `
        -Body $body `
        -ContentType "application/json"

    # Clean up
    Remove-Item $filePath -Force -EA SilentlyContinue
    return $response.id
}

# --- Helper: Create post ---
function New-WpPost($title, $content, $categoryId, $featuredMediaId, $altText) {
    $body = @{
        title   = $title
        content = $content
        status  = "publish"
        categories = @($categoryId)
    } | ConvertTo-Json

    if ($featuredMediaId) {
        $bodyObj = @{
            title   = $title
            content = $content
            status  = "publish"
            categories = @($categoryId)
            featured_media = $featuredMediaId
        } | ConvertTo-Json
    } else {
        $bodyObj = $body
    }

    $response = Invoke-RestMethod -Uri "$wpUrl/wp-json/wp/v2/posts" `
        -Headers $wpHeaders `
        -Method Post `
        -Body $bodyObj `
        -ContentType "application/json"

    return $response.link
}

# ============================================================
# POST 1: Ring Road in Mogilev
# ============================================================
Write-Host "=== Processing Post 1: Ring Road ==="

# Download image
$img1 = Get-ImageFile "https://images.pexels.com/photos/34338597/pexels-photo-34338597.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=627&w=1200" "road_construction.jpg"
$mediaId1 = Add-WpMedia $img1 "Стройновости: строительство кольцевой магистрали в Могилеве"
Write-Host "Media ID 1: $mediaId1"

$content1 = @"
<p>Могилёв обзаводится собственной внутригородской кольцевой магистралью — крупным инфраструктурным проектом, который изменит транспортную карту города. Строительные работы уже начались, и первый этап масштабной стройки в самом разгаре.</p>

<p>Новая дорога протяжённостью около 3,5 километров будет шестиполосной — по три полосы в каждом направлении. Проект предусматривает современную инфраструктуру: освещение, ограждения, съезды и въезды, отвечающие современным стандартам безопасности.</p>

<h2>Почему это важно для Могилёва</h2>

<p>Ежедневно через исторический центр города проходят тысячи автомобилей, создавая пробки и повышая нагрузку на и без того напряжённую улично-дорожную сеть. Новая кольцевая магистраль позволит вывести транзитный поток за пределы центра, пустив его по обходу через Днепр.</p>

<p>По предварительным расчётам, реализация проекта позволит:</p>
<ul>
<li>Разгрузить центр города от транзитного транспорта на 30–40%</li>
<li>Сократить время в пути для жителей пригородных районов</li>
<li>Улучшить экологическую обстановку в центральной части Могилёва</li>
<li>Повысить безопасность дорожного движения</li>
</ul>

<h2>Комментарий эксперта</h2>

<p>Строительство внутригородских обходных магистралей — мировой тренд в градостроительстве. Могилёв идёт в ногу со временем, реализуя проект, который окупится не только в транспортном, но и в экономическом отношении. Снижение загруженности центра напрямую влияет на стоимость коммерческой недвижимости и привлекательность города для инвесторов.</p>

<p>Для строительных компаний Могилёва это означает рост заказов на смежные работы: благоустройство прилегающих территорий, строительство подъездных путей, установка дорожных знаков и освещения. Стройновости Могилёв продолжают следить за ходом работ.</p>

<p><em>Фото: Pexels / Andrey Matveev</em></p>
"@

$link1 = New-WpPost "В Могилёве началось строительство внутригородской кольцевой магистрали" $content1 3 $mediaId1 "Стройновости строительство кольцевая магистраль Могилёв"
Write-Host "Post 1 published: $link1"

Start-Sleep 3

# ============================================================
# POST 2: 18-storey building in Mogilev
# ============================================================
Write-Host "=== Processing Post 2: 18-storey building ==="

$img2 = Get-ImageFile "https://images.pexels.com/photos/36065437/pexels-photo-36065437.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=627&w=1200" "highrise_construction.jpg"
$mediaId2 = Add-WpMedia $img2 "Стройновости: строительство 18-этажного дома в Могилеве Спутник-2"
Write-Host "Media ID 2: $mediaId2"

$content2 = @"
<p>В Могилёве начинается строительство нового 18-этажного многоквартирного жилого дома в микрорайоне «Спутник-2». УКС Могилёва приступает к реализации проекта, который завершит концепцию комплексной жилой застройки района.</p>

<p>Новостройка рассчитана на все категории дольщиков — как на тех, кто состоит на учёте нуждающихся в улучшении жилищных условий, так и на покупателей на коммерческом рынке. Это делает проект по-настоящему массовым и социально ориентированным.</p>

<h2>Планировки и стоимость</h2>

<p>Застройщик предлагает разнообразие квартир:</p>
<ul>
<li><strong>Однокомнатные:</strong> 45,37 – 48,96 м²</li>
<li><strong>Двухкомнатные:</strong> 61,43 – 62,88 м²</li>
<li><strong>Трёхкомнатные:</strong> 80,46 – 80,88 м²</li>
</ul>

<p>На первом этаже предусмотрено встроенное помещение коммерческого назначения площадью 53,94 м² — под магазин, офис или сервис.</p>

<p><strong>Стоимость 1 м²</strong> (без отделки):</p>
<ul>
<li>Для нуждающихся в улучшении жилищных условий: <strong>2 447,62 BYN</strong></li>
<li>Для коммерческих покупателей (ИП и юрлица): <strong>2 672,29 BYN</strong></li>
</ul>

<h2>Аналитика рынка</h2>

<p>Строительство «Спутник-2» — это завершающий элемент формирования микрорайона, где уже сложилась инфраструктура: школы, детские сады, магазины, транспортная доступность. Для покупателей, которые стоят на учёте, цена 2 447 BYN за квадрат — заметно ниже рыночной, что делает это предложение одним из самых привлекательных в Могилёве.</p>

<p>Количество квартир ограничено, приём заявлений стартовал ещё в ноябре 2024 года. Срок завершения строительства — ноябрь 2025 года. Стройновости Могилёв следит за динамикой строительства.</p>

<p><em>Фото: Pexels / Efe Burak Baydar</em></p>
"@

$link2 = New-WpPost "В Могилёве начинается строительство 18-этажного дома в микрорайоне Спутник-2" $content2 3 $mediaId2 "Стройновости 18-этажный дом Спутник-2 Могилёв"
Write-Host "Post 2 published: $link2"

Start-Sleep 3

# ============================================================
# POST 3: State-subsidized housing list
# ============================================================
Write-Host "=== Processing Post 3: State-subsidized housing ==="

$img3 = Get-ImageFile "https://images.pexels.com/photos/5155258/pexels-photo-5155258.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=627&w=1200" "housing_belarus.jpg"
$mediaId3 = Add-WpMedia $img3 "Стройновости: приоритетные стройки жилья с господдержкой Беларусь 2026"
Write-Host "Media ID 3: $mediaId3"

$content3 = @"
<p>В Беларуси утверждён перечень приоритетных строек жилья с государственной поддержкой на 2026 год. Соответствующее постановление Министерства строительства и архитектуры № 15 от 20 февраля 2026 года определило конкретные объекты, которые будут возводиться с использованием льготных кредитов.</p>

<h2>Что это значит на практике</h2>

<p>Включение объекта в перечень — это не просто формальность. Для застройщиков это гарантированный спрос и стабильное финансирование. Для покупателей — возможность получить жильё по льготной ставке кредитования, что существенно снижает итоговую стоимость квадратного метра.</p>

<p>В список вошли проекты из нескольких областей Беларуси. Это означает, что региональные программы строительства жилья получают федеральную финансовую поддержку, а граждане — реальный шанс улучшить жилищные условия на доступных условиях.</p>

<h2>Структурные изменения на рынке</h2>

<p>Одновременно правительство приняло ряд решений, меняющих правила строительства и кредитования жилья. Указы, подписанные в начале года, упрощают процедуры и снижают административные барьеры для застройщиков.</p>

<p>Параллельно правительство нацеливает строительный комплекс на работу «на максимуме». Премьер-министр Александр Турчин заявил о необходимости наверстать отставание, накопленное за зимние месяцы, и выйти на плановые показатели до конца первого квартала.</p>

<h2>Выводы для участников рынка</h2>

<p>Если вы — потенциальный покупатель жилья в Могилёве или области, следите за объявлениями УКС Могилёва. Объекты, включённые в программу льготного кредитования, дают реальную экономию. Если вы — строительная компания или подрядчик, это сигнал к активности: объёмы растут, сроки сжаты, спрос на рабочие руки и материалы увеличится.</p>

<p>Стройновости Могилёв — оперативные новости строительного рынка Беларуси.</p>

<p><em>Фото: Pexels / Egor Kunovsky (архитектура Минска)</em></p>
"@

$link3 = New-WpPost "В Беларуси определили приоритетные стройки жилья с господдержкой на 2026 год" $content3 3 $mediaId3 "Стройновости приоритетные стройки жильё господдержка 2026"
Write-Host "Post 3 published: $link3"

Write-Host ""
Write-Host "=== ALL DONE ==="
Write-Host "Post 1: $link1"
Write-Host "Post 2: $link2"
Write-Host "Post 3: $link3"
