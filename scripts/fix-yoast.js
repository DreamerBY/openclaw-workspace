// Fix Yoast SEO meta for the 3 posts
const https = require('https');
const fs = require('fs');
const creds = JSON.parse(fs.readFileSync('C:/Users/Wizard/.openclaw/credentials.json','utf8'));
const AUTH = Buffer.from('admin:' + creds.wordpress.app_password).toString('base64');
const WP = 'smeta1.by';

function req(method, path, body) {
    return new Promise((res, rej) => {
        const url = new URL('https://' + WP + path);
        const options = {
            hostname: url.hostname,
            path: url.pathname + url.search,
            method,
            headers: {
                'Authorization': 'Basic ' + AUTH,
                'Content-Type': 'application/json'
            }
        };
        const r = https.request(options, resp => {
            let d = '';
            resp.on('data', c => d += c);
            resp.on('end', () => {
                try { res(JSON.parse(d)); }
                catch { res({ raw: d, status: resp.statusCode }); }
            });
        });
        r.on('error', rej);
        if (body) r.write(JSON.stringify(body));
        r.end();
    });
}

const posts = [
    {
        id: 2710,
        slug: 'ring-road',
        title: 'В Могилёве началось строительство внутригородской кольцевой магистрали',
        desc: 'В Могилёве началось строительство внутригородской кольцевой магистрали протяжённостью 3.5 км. Шестиполосная дорога разгрузит центр города. Все подробности и значение для Могилёва на Стройновости Могилёв.',
        img: 'https://smeta1.by/wp-content/uploads/2026/03/ring-road-mogilev.jpg'
    },
    {
        id: 2712,
        slug: 'sputnik-2',
        title: 'В Могилёве начинается строительство 18-этажного дома в микрорайоне Спутник-2',
        desc: 'В Могилёве начинается строительство 18-этажного дома в микрорайоне Спутник-2. Планировки, цены от 2447 BYN/м2, сроки сдачи. Стройновости Могилёв — актуальные новости строительства.',
        img: 'https://smeta1.by/wp-content/uploads/2026/03/highrise-sputnik-mogilev.jpg'
    },
    {
        id: 2714,
        slug: 'goszhilshchchina-2026',
        title: 'В Беларуси утвердили приоритетные стройки жилья с господдержкой на 2026 год',
        desc: 'В Беларуси утверждён перечень приоритетных строек жилья с господдержкой на 2026 год. Льготное кредитование, стоимость квадрата, регионы. Стройновости Могилёв — аналитика и новости.',
        img: 'https://smeta1.by/wp-content/uploads/2026/03/housing-belarus-2026.jpg'
    }
];

async function fixPost(post) {
    console.log(`Fixing post ${post.id}: ${post.slug}`);
    try {
        const r = await req('POST', '/wp-json/wp/v2/posts/' + post.id, {
            meta: {
                yoast_wpseo_title: post.title + ' | Стройновости Могилёв',
                yoast_wpseo_metadesc: post.desc,
                yoast_wpseo_opengraph_image: post.img,
                yoast_wpseo_twitter_image: post.img
            }
        });
        console.log('  OK:', r.id, r.slug);
    } catch (e) {
        console.log('  ERROR:', JSON.stringify(e.body || e));
    }
    await new Promise(r => setTimeout(r, 1500));
}

async function main() {
    for (const post of posts) {
        await fixPost(post);
    }
    console.log('\nAll done!');
}

main().catch(console.error);
