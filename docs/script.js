document.addEventListener('DOMContentLoaded', () => {
    const navToggle = document.querySelector('.nav-toggle');
    const navLinks = document.getElementById('nav-links');

    if (navToggle && navLinks) {
        const setOpen = (open) => {
            navToggle.setAttribute('aria-expanded', String(open));
            navLinks.classList.toggle('is-open', open);
        };

        navToggle.addEventListener('click', () => {
            setOpen(navToggle.getAttribute('aria-expanded') !== 'true');
        });

        navLinks.querySelectorAll('a').forEach((link) => {
            link.addEventListener('click', () => setOpen(false));
        });

        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') {
                setOpen(false);
            }
        });
    }

    const header = document.querySelector('.site-header');
    let scrollAnimation = 0;

    const stopScrollAnimation = () => {
        if (scrollAnimation) {
            window.cancelAnimationFrame(scrollAnimation);
            scrollAnimation = 0;
        }
        document.documentElement.style.scrollBehavior = '';
    };

    const scrollToTarget = (target) => {
        const headerOffset = header ? header.offsetHeight + 8 : 0;
        const top = target.id === 'top'
            ? 0
            : Math.max(0, target.getBoundingClientRect().top + window.scrollY - headerOffset);
        const start = window.scrollY;
        const distance = top - start;

        if (Math.abs(distance) < 2) {
            return;
        }

        const duration = Math.min(1600, Math.max(700, Math.abs(distance) * 0.65));
        const startedAt = performance.now();
        const root = document.documentElement;
        root.style.scrollBehavior = 'auto';

        const step = (now) => {
            const elapsed = Math.min(1, (now - startedAt) / duration);
            const eased = elapsed < 0.5
                ? 4 * elapsed * elapsed * elapsed
                : 1 - Math.pow(-2 * elapsed + 2, 3) / 2;

            window.scrollTo(0, Math.round(start + distance * eased));

            if (elapsed < 1) {
                scrollAnimation = window.requestAnimationFrame(step);
            } else {
                scrollAnimation = 0;
                root.style.scrollBehavior = '';
            }
        };

        scrollAnimation = window.requestAnimationFrame(step);
    };

    document.querySelectorAll('a[href^="#"]').forEach((link) => {
        const hash = link.getAttribute('href');
        if (hash.length < 2) {
            return;
        }

        const target = document.getElementById(hash.slice(1));
        if (!target) {
            return;
        }

        link.addEventListener('click', (event) => {
            event.preventDefault();
            stopScrollAnimation();
            scrollToTarget(target);
            if (location.protocol !== 'file:') {
                history.pushState(null, '', hash);
            }
        });
    });

    ['wheel', 'touchstart'].forEach((eventName) => {
        window.addEventListener(eventName, stopScrollAnimation, { passive: true });
    });

    document.addEventListener('keydown', (event) => {
        const scrollKeys = ['ArrowUp', 'ArrowDown', 'PageUp', 'PageDown', 'Home', 'End', ' '];
        if (scrollKeys.includes(event.key)) {
            stopScrollAnimation();
        }
    });

    const scrollProgress = document.querySelector('.scroll-progress');
    const scrubElements = [...document.querySelectorAll('.reveal.scrub')];
    const sectionLinks = [...document.querySelectorAll('.nav-links a[href^="#"]')];
    const sections = sectionLinks
        .map((link) => document.querySelector(link.getAttribute('href')))
        .filter(Boolean);

    if (scrollProgress || scrubElements.length || sections.length) {
        let ticking = false;

        const updateScroll = () => {
            ticking = false;

            if (scrollProgress) {
                const max = document.documentElement.scrollHeight - window.innerHeight;
                const progress = max > 0 ? Math.min(1, Math.max(0, window.scrollY / max)) : 0;
                scrollProgress.style.setProperty('--scroll', progress.toFixed(4));
            }

            if (scrubElements.length) {
                const startLine = window.innerHeight * 0.92;
                const endLine = window.innerHeight * 0.5;
                const span = Math.max(1, startLine - endLine);

                scrubElements.forEach((element) => {
                    const top = element.getBoundingClientRect().top;
                    const reveal = Math.min(1, Math.max(0, (startLine - top) / span));
                    element.style.setProperty('--reveal', reveal.toFixed(3));
                });
            }

            if (sections.length) {
                const marker = Math.min(window.innerHeight * 0.4, 360);
                let current = null;
                sections.forEach((section) => {
                    if (section.getBoundingClientRect().top <= marker) {
                        current = section;
                    }
                });

                const atBottom = window.scrollY + window.innerHeight >= document.documentElement.scrollHeight - 2;
                if (atBottom) {
                    current = sections[sections.length - 1];
                }

                sectionLinks.forEach((link) => {
                    const isActive = current !== null && link.getAttribute('href') === `#${current.id}`;
                    link.classList.toggle('is-active', isActive);
                });
            }
        };

        const onScroll = () => {
            if (ticking) {
                return;
            }
            ticking = true;
            window.requestAnimationFrame(updateScroll);
        };

        window.addEventListener('scroll', onScroll, { passive: true });
        window.addEventListener('resize', onScroll);
        updateScroll();
    }

    const revealElements = document.querySelectorAll('.reveal');
    if (revealElements.length) {
        if ('IntersectionObserver' in window && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
            const observer = new IntersectionObserver((entries) => {
                entries.forEach((entry) => {
                    if (!entry.isIntersecting) {
                        return;
                    }
                    entry.target.classList.add('is-visible');
                    observer.unobserve(entry.target);
                });
            }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });

            revealElements.forEach((element) => observer.observe(element));
        } else {
            revealElements.forEach((element) => element.classList.add('is-visible'));
        }
    }

    document.querySelectorAll('.compare-media').forEach((media) => {
        const range = media.querySelector('.compare-range');
        if (!range) {
            return;
        }

        const update = () => {
            media.style.setProperty('--split', `${range.value}%`);
        };

        range.addEventListener('input', update);
        update();
    });

    const releaseLabel = document.getElementById('release-label');
    const downloadButton = document.getElementById('download-btn');
    const repository = 'ReForge-MMD/ray-mmd-reforge';
    const apiRoot = `https://api.github.com/repos/${repository}`;
    const dateFormatter = new Intl.DateTimeFormat('en', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
    });

    const create = (tag, className, text) => {
        const element = document.createElement(tag);
        if (className) {
            element.className = className;
        }
        if (text !== undefined) {
            element.textContent = text;
        }
        return element;
    };

    const formatDate = (value) => {
        const date = new Date(value);
        return Number.isNaN(date.getTime()) ? '' : dateFormatter.format(date);
    };

    const showUnavailable = (container, message) => {
        container.replaceChildren(create('p', 'log-empty', message));
    };

    const loadLatestRelease = async () => {
        try {
            const response = await fetch(`${apiRoot}/releases/latest`, {
                headers: { Accept: 'application/vnd.github+json' },
            });
            if (!response.ok) {
                throw new Error(`GitHub responded with ${response.status}`);
            }

            const release = await response.json();
            if (downloadButton && release.html_url) {
                downloadButton.href = release.html_url;
            }
            if (releaseLabel && release.tag_name) {
                releaseLabel.textContent = `Stable release ${release.tag_name}`;
            }
        } catch {
            if (releaseLabel) {
                releaseLabel.textContent = 'Stable release v1.24.0';
            }
        }
    };

    const loadReleases = async () => {
        const container = document.getElementById('stable-changelog');
        if (!container) {
            return;
        }

        try {
            const response = await fetch(`${apiRoot}/releases`, {
                headers: { Accept: 'application/vnd.github+json' },
            });
            if (!response.ok) {
                throw new Error(`GitHub responded with ${response.status}`);
            }

            const releases = await response.json();
            if (!Array.isArray(releases) || releases.length === 0) {
                showUnavailable(container, 'No releases found');
                return;
            }

            const items = releases.slice(0, 4).map((release) => {
                const item = create('article', 'log-item');
                const head = create('div', 'log-item-head');
                const title = create('a', 'log-title', release.name || release.tag_name);
                title.href = release.html_url;
                title.target = '_blank';
                title.rel = 'noreferrer';

                const date = create('time', 'log-date', formatDate(release.published_at));
                date.dateTime = release.published_at;

                head.append(title, date);
                item.append(head);
                return item;
            });

            container.replaceChildren(...items);
        } catch {
            showUnavailable(container, 'GitHub data is unavailable');
        }
    };

    const loadCommits = async () => {
        const container = document.getElementById('master-changelog');
        if (!container) {
            return;
        }

        try {
            const response = await fetch(`${apiRoot}/commits?sha=master&per_page=8`, {
                headers: { Accept: 'application/vnd.github+json' },
            });
            if (!response.ok) {
                throw new Error(`GitHub responded with ${response.status}`);
            }

            const commits = await response.json();
            if (!Array.isArray(commits) || commits.length === 0) {
                showUnavailable(container, 'No commits found');
                return;
            }

            const items = commits.slice(0, 8).map((commit) => {
                const item = create('article', 'log-item');
                const row = create('div', 'log-row');
                const sha = create('a', 'log-sha', commit.sha.slice(0, 7));
                sha.href = commit.html_url;
                sha.target = '_blank';
                sha.rel = 'noreferrer';

                const message = commit.commit.message.split('\n')[0];
                const text = create('span', 'log-message', message);
                text.title = message;

                row.append(sha, text);

                const author = commit.commit.author && commit.commit.author.name
                    ? commit.commit.author.name
                    : 'unknown';
                const date = formatDate(commit.commit.author ? commit.commit.author.date : '');
                const meta = create('div', 'log-meta', date ? `by ${author} on ${date}` : `by ${author}`);

                item.append(row, meta);
                return item;
            });

            container.replaceChildren(...items);
        } catch {
            showUnavailable(container, 'GitHub data is unavailable');
        }
    };

    loadLatestRelease();
    loadReleases();
    loadCommits();
});
