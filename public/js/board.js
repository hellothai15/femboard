// Board-specific JavaScript

// Modal handling
function openNewThreadModal() {
  const modal = document.getElementById('newThreadModal');
  if (modal) {
    modal.classList.add('active');
    document.body.style.overflow = 'hidden';
  }
}

function closeNewThreadModal() {
  const modal = document.getElementById('newThreadModal');
  if (modal) {
    modal.classList.remove('active');
    document.body.style.overflow = '';
  }
}

// Quote post
function quotePost(postId) {
  const postContent = document.querySelector(#post- .post-content);
  const replyTextarea = document.getElementById('replyContent');
  
  if (postContent && replyTextarea) {
    const text = postContent.innerText.trim();
    const quotedText = text.split('\n').map(line => > ).join('\n');
    replyTextarea.value += ${quotedText}\n\n;
    replyTextarea.focus();
    replyTextarea.scrollIntoView({ behavior: 'smooth' });
  }
}

// Close modal on Escape
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    closeNewThreadModal();
  }
});

// Character counter for thread title
document.addEventListener('DOMContentLoaded', () => {
  const titleInput = document.getElementById('title');
  if (titleInput) {
    titleInput.addEventListener('input', () => {
      const remaining = 200 - titleInput.value.length;
      const counter = titleInput.parentElement.querySelector('.char-counter');
      if (counter) {
        counter.textContent = ${remaining} characters remaining;
        counter.style.color = remaining < 20 ? 'var(--error)' : 'var(--neutral-400)';
      }
    });
  }
});
