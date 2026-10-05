document.addEventListener('DOMContentLoaded', () => {
    // Intersection Observer for scroll animations
    const fadeElements = document.querySelectorAll('.fade-in');
    
    const appearOptions = {
        threshold: 0.1,
        rootMargin: "0px 0px -50px 0px"
    };

    const appearOnScroll = new IntersectionObserver(function(entries, observer) {
        entries.forEach(entry => {
            if (!entry.isIntersecting) {
                return;
            } else {
                entry.target.classList.add('appear');
                observer.unobserve(entry.target);
            }
        });
    }, appearOptions);

    fadeElements.forEach(element => {
        appearOnScroll.observe(element);
    });

    // Navbar scroll effect
    const navbar = document.querySelector('.navbar');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.style.padding = '1rem 0';
            navbar.style.background = 'rgba(15, 20, 25, 0.95)';
        } else {
            navbar.style.padding = '1.5rem 0';
            navbar.style.background = 'rgba(15, 20, 25, 0.8)';
        }
    });

    // Comparison Sliders Logic
    const sliders = document.querySelectorAll('.comparison-slider');
    sliders.forEach(slider => {
        const input = slider.querySelector('.slider-input');
        const beforeWrapper = slider.querySelector('.img-before-wrapper');
        const sliderLine = slider.querySelector('.slider-line');
        const sliderButton = slider.querySelector('.slider-button');

        input.addEventListener('input', (e) => {
            const value = e.target.value;
            beforeWrapper.style.clipPath = `inset(0 ${100 - value}% 0 0)`;
            sliderLine.style.left = `${value}%`;
            sliderButton.style.left = `${value}%`;
        });
    });

    // Dropdown toggle logic for Download button
    const dropdownToggle = document.getElementById('download-dropdown-btn');
    const dropdownMenu = document.querySelector('.dropdown-menu');

    if (dropdownToggle && dropdownMenu) {
        dropdownToggle.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            dropdownMenu.classList.toggle('show');
        });
        
        document.addEventListener('click', () => {
            dropdownMenu.classList.remove('show');
        });
    }

    // GitHub API Fetch (automatically fetches the latest release tag)
    const downloadBtn = document.getElementById('download-btn');
    const downloadStable = document.getElementById('download-stable');
    
    if (downloadBtn) {
        const repo = 'ReForge-MMD/ray-mmd-reforge';
        
        fetch(`https://api.github.com/repos/${repo}/releases/latest`)
            .then(response => response.json())
            .then(data => {
                if (data.tag_name) {
                    // Main button downloads the stable release
                    downloadBtn.textContent = `Download ${data.tag_name}`;
                    downloadBtn.href = data.html_url; 
                    
                    // Dropdown option explicitly lists stable release
                    if (downloadStable) {
                        downloadStable.textContent = `Stable Release (${data.tag_name})`;
                        downloadStable.href = data.html_url;
                    }
                }
            })
            .catch(error => {
                console.error("Failed to fetch release info:", error);
            });
    }

    // ponytail: minimum changelog logic, unauthenticated GitHub API (limit 60/hr)
    const stableChangelog = document.getElementById('stable-changelog');
    if (stableChangelog) {
        const cacheKey = 'ray_mmd_changelog_cache_v1';
        const cacheTimeKey = 'ray_mmd_changelog_time_v1';
        const now = Date.now();
        const cachedHtml = localStorage.getItem(cacheKey);
        const cachedTime = localStorage.getItem(cacheTimeKey);

        // Cache valid for 1 hour (3600000 ms)
        if (cachedHtml && cachedTime && (now - cachedTime < 3600000)) {
            stableChangelog.innerHTML = cachedHtml;
        } else {
            fetch('https://api.github.com/repos/ReForge-MMD/ray-mmd-reforge/releases')
                .then(res => res.json())
                .then(async data => {
                    if (!Array.isArray(data)) throw new Error("API Limit");
                    const releases = data.slice(0, 3);
                    let html = '';
                    for (const release of releases) {
                        html += `
                            <div style="border-bottom: 1px solid rgba(255,255,255,0.05); padding-bottom: 0.5rem; margin-bottom: 0.5rem;">
                                <a href="${release.html_url}" target="_blank" style="color: #A3BE8C; text-decoration: none; font-weight: 600;">${release.name || release.tag_name}</a>
                                <span style="font-size: 0.85rem; color: #64869e; margin-left: 8px;">${new Date(release.published_at).toLocaleDateString()}</span>
                                <div style="margin-top: 8px; padding-left: 12px; border-left: 2px solid rgba(163, 190, 140, 0.3);">
                        `;
                        try {
                            const commitsRes = await fetch(`https://api.github.com/repos/ReForge-MMD/ray-mmd-reforge/commits?sha=${release.tag_name}&per_page=3`);
                            const commits = await commitsRes.json();
                            if (commits && commits.length) {
                                html += commits.map(commit => `
                                    <div style="font-size: 0.85rem; margin-bottom: 4px; display: flex; gap: 6px; align-items: baseline;">
                                        <a href="${commit.html_url}" target="_blank" style="color: #81A1C1; text-decoration: none; font-family: monospace; flex-shrink: 0;">${commit.sha.substring(0,7)}</a>
                                        <span style="color: #e2e8f0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: block; width: 100%;">${commit.commit.message.split('\\n')[0]}</span>
                                    </div>
                                `).join('');
                                html += `<div style="font-size: 0.85rem; margin-top: 6px;"><a href="https://github.com/ReForge-MMD/ray-mmd-reforge/commits/${release.tag_name}" target="_blank" style="color: #64869e; text-decoration: none; transition: color 0.2s;">View all changes &rarr;</a></div>`;
                            }
                        } catch(e) {
                            html += `<div style="font-size: 0.85rem; color: #64869e;">Failed to load commits.</div>`;
                        }
                        html += `</div></div>`;
                    }
                    const finalHtml = html || '<p>No releases found.</p>';
                    stableChangelog.innerHTML = finalHtml;
                    localStorage.setItem(cacheKey, finalHtml);
                    localStorage.setItem(cacheTimeKey, now);
                }).catch(() => {
                    if (cachedHtml) {
                        stableChangelog.innerHTML = cachedHtml; // Fallback to stale cache
                    } else {
                        stableChangelog.innerHTML = '<p>Failed to load GitHub data (API limit reached).</p>';
                    }
                });
        }
    }

    const masterChangelog = document.getElementById('master-changelog');
    if (masterChangelog) {
        fetch('https://api.github.com/repos/ReForge-MMD/ray-mmd-reforge/commits?sha=master')
            .then(res => res.json())
            .then(data => {
                masterChangelog.innerHTML = data.slice(0, 10).map(commit => `
                    <div style="border-bottom: 1px solid rgba(255,255,255,0.05); padding-bottom: 0.5rem; display: flex; flex-direction: column;">
                        <div style="display: flex; gap: 6px; align-items: baseline; overflow: hidden;">
                            <a href="${commit.html_url}" target="_blank" style="color: #81A1C1; text-decoration: none; font-weight: 600; font-family: monospace; flex-shrink: 0;">${commit.sha.substring(0,7)}</a>
                            <span style="font-size: 0.9rem; color: #e2e8f0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: block; width: 100%;">${commit.commit.message.split('\\n')[0]}</span>
                        </div>
                        <div style="font-size: 0.8rem; color: #64869e; margin-top: 4px;">by ${commit.commit.author.name} on ${new Date(commit.commit.author.date).toLocaleDateString()}</div>
                    </div>
                `).join('') || '<p>No commits found.</p>';
            }).catch(() => masterChangelog.innerHTML = '<p>Failed to load.</p>');
    }
});
