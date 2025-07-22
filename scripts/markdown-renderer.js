/**
 * 自定义Markdown渲染器，修改标题级别
 * 使 ## 渲染为 <h3> 而不是 <h2>
 */

'use strict';

// 在Hexo初始化完成后执行
hexo.extend.filter.register('after_post_render', function(data) {
  // 替换文章内容中的标题标签
  data.content = data.content
    .replace(/<h2 id="([^"]+)">/g, '<h3 id="$1">')
    .replace(/<\/h2>/g, '</h3>');
  
  return data;
}); 