/**
 * Allowed tags for snippets
 * This helps maintain consistency and prevents tag pollution
 */
const ALLOWED_TAGS = [
  // UI Components
  'button',
  'card',
  'input',
  'text',
  'image',
  'icon',
  'badge',
  'chip',
  'avatar',
  'list',
  'grid',
  'stack',
  'spacer',
  'divider',
  'separator',
  
  // Navigation
  'navigation',
  'tab',
  'menu',
  'sidebar',
  'header',
  'footer',
  'breadcrumb',
  
  // Forms
  'form',
  'field',
  'picker',
  'selector',
  'toggle',
  'switch',
  'slider',
  'stepper',
  'checkbox',
  'radio',
  
  // Layout
  'layout',
  'container',
  'section',
  'modal',
  'sheet',
  'popover',
  'tooltip',
  'overlay',
  
  // Data Display
  'table',
  'chart',
  'graph',
  'timeline',
  'calendar',
  'progress',
  'meter',
  'stat',
  'metric',
  
  // Feedback
  'alert',
  'notification',
  'toast',
  'loading',
  'spinner',
  'skeleton',
  'empty',
  'error',
  'success',
  'warning',
  
  // Media
  'video',
  'audio',
  'player',
  'gallery',
  'carousel',
  
  // Animation
  'animation',
  'transition',
  'motion',
  'gesture',
  'interaction',
  
  // Theming
  'theme',
  'color',
  'gradient',
  'shadow',
  'border',
  'radius',
  
  // Utility
  'utility',
  'helper',
  'wrapper',
  'responsive',
  'adaptive',
  
  // Platform
  'ios',
  'macos',
  'watchos',
  'tvos',
  
  // Category
  'ui',
  'component',
  'screen',
  'view',
  'widget',
  'element',
  
  // State
  'state',
  'interactive',
  'static',
  'dynamic',
  
  // Size
  'small',
  'medium',
  'large',
  'compact',
  'expanded',
  
  // Style
  'minimal',
  'modern',
  'classic',
  'elegant',
  'bold',
  'subtle',
  
  // Function
  'auth',
  'login',
  'signup',
  'profile',
  'settings',
  'search',
  'filter',
  'sort',
  'action',
  'control'
];

/**
 * Check if a tag is allowed
 */
function isAllowedTag(tag) {
  return ALLOWED_TAGS.includes(tag);
}

/**
 * Get suggested tags for a given tag (for fuzzy matching)
 */
function getSuggestedTags(inputTag) {
  const lowerInput = inputTag.toLowerCase();
  return ALLOWED_TAGS.filter(tag => 
    tag.toLowerCase().includes(lowerInput) || 
    lowerInput.includes(tag.toLowerCase())
  ).slice(0, 5); // Return max 5 suggestions
}

module.exports = {
  ALLOWED_TAGS,
  isAllowedTag,
  getSuggestedTags
};
